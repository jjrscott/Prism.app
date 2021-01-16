//
//  Document.m
//  Prism
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "Document.h"
#import <PrismCommon/PrismCommon.h>
#import "LayoutManager.h"

@interface Document ()

@property (nonatomic, weak) IBOutlet NSTextView *textView;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, weak) IBOutlet NSPopUpButton *languageButton;
@property (nonatomic, weak) IBOutlet NSButton *debugButton;

@property (nonatomic, strong) NSString *currentLanguage;

@property (nonatomic, strong) NSMutableDictionary <NSString*, Class<Tokeniser>>* availableLanguages;

@end

@implementation Document

+ (BOOL)autosavesInPlace {
    return NO;
}

+ (BOOL)autosavesDraft {
    return NO;
}

- (NSString *)windowNibName {
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    self.layoutManager = [LayoutManager new];
    [self.textView.textContainer replaceLayoutManager:self.layoutManager];
    
    self.availableLanguages = NSMutableDictionary.new;
    
    for (Class<Tokeniser> tokenizer in @[Prism.class, PlainTextTokeniser.class, Bulkhead.class, BinaryTokeniser.class]) {
        for (NSString *language in [tokenizer availableLanguages]) {
            self.availableLanguages[language] = tokenizer;
        }
    }

    [self.languageButton removeAllItems];
    
    NSArray *availableLanguages = [self.availableLanguages.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableDictionary *languageTitles = NSMutableDictionary.new;
    for (NSString *availableLanguage in availableLanguages) {
        NSDictionary *declaration = [UTType copyDeclarationInUTI:availableLanguage];
        languageTitles[availableLanguage] = NSLocalizedStringWithDefaultValue(availableLanguage, nil, NSBundle.mainBundle, declaration[@"UTTypeDescription"], @"");
    }
    
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        DumpStrings(languageTitles);
    });
    
    availableLanguages = [availableLanguages sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [languageTitles[obj1] caseInsensitiveCompare:languageTitles[obj2]];
    }];
    for (NSString *availableLanguage in availableLanguages) {
        NSMenuItem *menutItem = [[NSMenuItem alloc] initWithTitle:languageTitles[availableLanguage] 
                                                           action:@selector(selectLanguage:)
                                                    keyEquivalent:@""];
        menutItem.representedObject = availableLanguage;
        [self.languageButton.menu addItem:menutItem];
    }
    [self refreshContent:nil];
}

- (IBAction)enableDebug:(NSButton*)sender {
    self.currentLanguage = self.languageButton.selectedItem.representedObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContent:sender];
    });
}

- (IBAction)selectLanguage:(id)sender {
    self.currentLanguage = self.languageButton.selectedItem.representedObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContent:sender];
    });
}

-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError {
    
    self.localPath = url.path;
    return YES;
}

- (NSString*)suggestedLanguageForUTIs:(NSArray <NSString *>*)utis {
    for (NSString *uti in utis) {
        Print(@"uti: %@", uti);
        if (self.availableLanguages[uti]) {
            return uti;
        }
    }
    
    for (NSString *uti in utis) {
        NSDictionary *declaration = [UTType copyDeclarationInUTI:uti];
        NSString *suggestedUTI = [self suggestedLanguageForUTIs:declaration[@"UTTypeConformsTo"]];
        if (suggestedUTI) return suggestedUTI;
    }

    return nil;
}

- (NSString*)suggestedLanguageForPath:(NSString *)path {
    
    NSData *standardOutput = nil;
    [NSTask executeTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/file"]
                               arguments:@[@"--mime-type", @"--brief", path]
                           standardInput:nil
                          standardOutput:&standardOutput
                           standardError:NULL
                                   error:NULL];
    
    NSString *mimeType = [[NSString alloc] initWithData:standardOutput encoding:NSASCIIStringEncoding];
    
    mimeType = [mimeType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSDictionary *mimeTypes = @{
                                @"text/x-ruby" : @"public.ruby-script",
                                @"text/x-tex" : @"org.tug.tex",
                                };
    
    Print(@"mimeType: %@", mimeType);
    
    if (mimeTypes[mimeType]) return mimeTypes[mimeType];
    
    
    
    NSString *preferredIdentifier = [UTType createPreferredIdentifierForTagInTagClass:UTTagClassFilenameExtension
                                                                                inTag:path.pathExtension
                                                                    inConformingToUTI:nil];
    
    Print(@"preferredIdentifier: %@", preferredIdentifier);

    return [self suggestedLanguageForUTIs:@[preferredIdentifier]];
}

- (NSArray*)tokenizePath:(NSString *)path language:(NSString *)language error:(NSError **)error
{
    NSData *content = [NSData dataWithContentsOfFile:path options:kNilOptions error:error];
    
    return [self.availableLanguages[language] tokenizeData:content language:language error:NULL];
}

- (IBAction)refreshContent:(id)sender {
    
    Print(@"Refresh Content");
    
    if (!self.localPath) return;
    
    if (self.remotePath) {
        self.windowForSheet.title = [NSString stringWithFormat:@"%@ ⇄ %@", self.localPath.lastPathComponent, self.remotePath.lastPathComponent];
    }
    
    NSString *language = self.currentLanguage;
    
    if (!language) {
        language = [self suggestedLanguageForPath:self.localPath];
    }
    
    NSArray *content = [self tokenizePath:self.localPath
                                 language:language
                                    error:NULL];
    
    NSAttributedString *buffer;
    
    if (self.remotePath) {
        NSArray *remoteContent = [self tokenizePath:self.remotePath
                                           language:language
                                              error:NULL];
        
        content = [NSObject differenceWithLeft:content right:remoteContent];
    }
    
    BOOL shouldForceDebug = self.availableLanguages[language] == Bulkhead.class;
    
    if (shouldForceDebug) self.debugButton.state = NSControlStateValueOn;
    self.debugButton.enabled = !shouldForceDebug;
    
    if (self.debugButton.state == NSControlStateValueOn) {
        buffer = [JJRSObjectDescription attributedDescriptionForObject:content];
    } else if (content) {
        buffer = [self attributedStringFromValue:content action:nil];
        
        buffer = [self splitLines:buffer];
//        buffer = [JJRSObjectDescription attributedDescriptionForObject:tokens];
        
    } else {
        buffer = NSAttributedString.new;
    }
    
    self.currentLanguage = language;
    
    [self.languageButton selectItemWithRepresentedObject:language];
    
    self.textView.backgroundColor = [NSColor colorFromXCColorThemeString:@"0.118 0.125 0.157 1"];
    [self.textView.textStorage setAttributedString:buffer];
}

-(NSAttributedString *)attributedStringFromValue:(id)value action:(NSString*)action
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    attributes[@"PrismPatchAction"] = action;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    attributes[NSBaselineOffsetAttributeName] = @(-paragraphStyle.lineSpacing);
    attributes[NSForegroundColorAttributeName] = NSColor.whiteColor;
    attributes[NSFontAttributeName] = [NSFont userFixedPitchFontOfSize:11];
    return [self attributedStringFromValue:value baseAttributes:attributes];
}

-(NSColor*)colorForType:(NSString*)type key:(NSString*)key {
    if ([type isEqual:@"boolean"]) {
        return [NSColor colorFromXCColorThemeString:@"0.698 0.095 0.536 1"];
    } else if ([type isEqual:@"class-name"]) {
        return [NSColor colorFromXCColorThemeString:@"0.57 0.57 0.57 1"];
    } else if ([type isEqual:@"comment"]) {
        return [NSColor colorFromXCColorThemeString:@"0.254902 0.713725 0.270588 1"];
    } else if ([type isEqual:@"shebang"]) {
        return [NSColor colorFromXCColorThemeString:@"0.254902 0.713725 0.270588 1"];
    } else if ([type isEqual:@"directive"]) {
        return [NSColor colorFromXCColorThemeString:@"0.778 0.488 0.284 1"];
    } else if ([type isEqual:@"keyword"] || [type isEqual:@"prolog"] || [type isEqual:@"tag"]) {
        return [NSColor colorFromXCColorThemeString:@"0.698 0.095 0.536 1"];
    } else if ([type isEqual:@"number"]) {
        return [NSColor colorFromXCColorThemeString:@"0.469 0.426 0.77 1"];
    } else if ([type isEqual:@"regex"]) {
        return [NSColor colorFromXCColorThemeString:@"0.859 0.171 0.219 1"];
    } else if ([type isEqual:@"string"]) {
        return [NSColor colorFromXCColorThemeString:@"0.859 0.171 0.219 1"];
    } else if ([type isEqual:@"url"]) {
        return [NSColor colorFromXCColorThemeString:@"0.255 0.333 0.819 1"];
    } else if ([type isEqual:@"macro"]) {
        return [NSColor colorFromXCColorThemeString:@"0.778 0.488 0.284 1"];
    } else if ([type isEqual:@"function"]) {
        return [NSColor colorFromXCColorThemeString:@"0.572549 0.572549 0.572549 1"];
    } else if ([type isEqual:@"constant"]) {
        return [NSColor colorFromXCColorThemeString:@"0.572549 0.572549 0.572549 1"];
    }
    
    static NSMutableSet *unknownTypes = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        unknownTypes = [NSMutableSet new];
    });
    if (![unknownTypes containsObject:type]) {
        Print(@"Unknown %@: '%@'", key, type);
        [unknownTypes addObject:type];
    }
    return nil;
}

-(NSAttributedString*)splitLines:(NSAttributedString *)attributedString {
    NSMutableArray *lines = [NSMutableArray new];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\n]+)" options:kNilOptions error:NULL];
    [regex enumerateMatchesInString:attributedString.string
                            options:kNilOptions
                              range:NSMakeRange(0, attributedString.length)
                         usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                             [lines addObject:[attributedString attributedSubstringFromRange:result.range]];
                         }];
    
    
    NSMutableAttributedString *buffer = NSMutableAttributedString.new;

    for (NSAttributedString *line in lines) {
        
        NSMutableAttributedString *leftBuffer = NSMutableAttributedString.new;
        NSMutableAttributedString *rightBuffer = NSMutableAttributedString.new;
        
        [line enumerateAttribute:@"PrismPatchAction"
                         inRange:NSMakeRange(0, line.length)
                         options:kNilOptions
                      usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                          if ([value isEqual:@"remove"]) {
                              [leftBuffer appendAttributedString:[line attributedSubstringFromRange:range]];
                          } else if ([value isEqual:@"insert"]) {
                              [rightBuffer appendAttributedString:[line attributedSubstringFromRange:range]];
                          } else {
                              [leftBuffer appendAttributedString:[line attributedSubstringFromRange:range]];
                              [rightBuffer appendAttributedString:[line attributedSubstringFromRange:range]];
                          }
                      }];
        
        if ([leftBuffer isEqual:rightBuffer])
        {
            [buffer appendAttributedString:leftBuffer];
            [buffer appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        } else {
            if (leftBuffer.length) {
                [leftBuffer appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                [leftBuffer addAttribute:NSBackgroundColorAttributeName
                                   value:[NSColor colorFromXCColorThemeString:@"0.26 0.16 0.17 1"]
                                   range:NSMakeRange(0, leftBuffer.length)];
                
                [buffer appendAttributedString:leftBuffer];
            }
            if (rightBuffer.length) {
                [rightBuffer appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                [rightBuffer addAttribute:NSBackgroundColorAttributeName
                                   value:[NSColor colorFromXCColorThemeString:@"0.16 0.24 0.18 1"]
                                   range:NSMakeRange(0, rightBuffer.length)];
                
                [buffer appendAttributedString:rightBuffer];
            }
        }
        
        
    }
    
    return buffer.copy;
}

-(NSAttributedString *)attributedStringFromValue:(id)value baseAttributes:(NSDictionary*)baseAttributes
{
    if ([value isKindOfClass:NSString.class])
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:baseAttributes];
        if ([value isEqual:@"\n"]) {
            attributes[NSBackgroundColorAttributeName] = nil;
        }
        return [[NSAttributedString alloc] initWithString:value attributes:attributes];
    } else if ([value isKindOfClass:NSDictionary.class]) {
        NSString *content = [value objectForKey:@"content"];
        NSString *type = [value objectForKey:@"type"];


        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:baseAttributes];
        
        NSColor *color = [self colorForType:type key:@"type"];
        
        if (!color) {
            NSString *alias = [value objectForKey:@"alias"];
            if (alias) {
                color = [self colorForType:alias key:@"alias"];
            }
        }
        
        if (color) {
            attributes[NSForegroundColorAttributeName] = color;
        }
        return [self attributedStringFromValue:content baseAttributes:attributes];
    } else if ([value isKindOfClass:NSArray.class]) {
        NSMutableAttributedString *buffer = [NSMutableAttributedString new];
        for (id subvalue in value) {
            [buffer appendAttributedString:[self attributedStringFromValue:subvalue baseAttributes:baseAttributes]];
        }
        return buffer.copy;
    } else if ([value isKindOfClass:Patch.class]) {
        NSMutableAttributedString *buffer = [NSMutableAttributedString new];

        Patch *patch = value;
        if (patch.left)
        {
            NSAttributedString *string = [self attributedStringFromValue:patch.left action:@"remove"];
            [buffer appendAttributedString:string];
        }
        if (patch.right)
        {
            NSAttributedString *string = [self attributedStringFromValue:patch.right action:@"insert"];
            [buffer appendAttributedString:string];
        }
        return buffer.copy;
    }
    abort();
}

- (void)restoreStateWithCoder:(NSCoder *)coder {
    [super restoreStateWithCoder:coder];
    [coder decodeProperty:@selector(cliToken) toObject:self];
    [coder decodeProperty:@selector(localPath) toObject:self];
    [coder decodeProperty:@selector(remotePath) toObject:self];
    [coder decodeProperty:@selector(currentLanguage) toObject:self];
    [coder decodeProperty:@selector(state) toObject:self.debugButton];
    [self refreshContent:self];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeProperty:@selector(cliToken) fromObject:self];
    [coder encodeProperty:@selector(localPath) fromObject:self];
    [coder encodeProperty:@selector(remotePath) fromObject:self];
    [coder encodeProperty:@selector(currentLanguage) fromObject:self];
    [coder encodeProperty:@selector(state) fromObject:self.debugButton];
    [super encodeRestorableStateWithCoder:coder];
}

@end
