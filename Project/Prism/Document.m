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

@property (nonatomic, strong) NSDictionary *currentTheme;

@property (nonatomic, strong) NSMutableSet <NSString*>* availableLanguages;

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
    
    Prism *prism = [Prism new];
    
    NSArray *availableLanguages = [prism availableLanguages];
    
    self.availableLanguages = NSMutableSet.new;
    
    [self.availableLanguages addObjectsFromArray:availableLanguages];
    
    [self.languageButton removeAllItems];
    
    NSMutableDictionary *languageTitles = NSMutableDictionary.new;
    for (NSString *availableLanguage in availableLanguages) {
        NSDictionary *declaration = [UTType copyDeclarationInUTI:availableLanguage];
        languageTitles[availableLanguage] = declaration[@"UTTypeDescription"] ?: NSLocalizedString(availableLanguage, @"");
    }
    
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

void Conforms(NSString *uti, NSMutableArray *parentUTIs) {
    
    [parentUTIs addObject:uti];
    [parentUTIs addObject:@"\n"];
    NSArray *parentUtis = [UTType copyDeclarationInUTI:uti][(__bridge id)kUTTypeConformsToKey];
    
    for (NSString* parentUti in parentUtis) {
        Conforms(parentUti, parentUTIs);
    }
}

- (NSString*)suggestedLanguageForPath:(NSString *)path {
    NSString *preferredIdentifier = [UTType createPreferredIdentifierForTagInTagClass:UTTagClassFilenameExtension
                                                                                inTag:path.pathExtension
                                                                    inConformingToUTI:nil];
    
    NSMutableArray *parentUTIs = [NSMutableArray new];
    Conforms(preferredIdentifier, parentUTIs);
    
    for (NSString *conformsToUTI in parentUTIs) {
        if ([self.availableLanguages containsObject:conformsToUTI]) {
            return conformsToUTI;
        }
    }
    return nil;
}

- (NSArray*)tokenizePath:(NSString *)path language:(NSString *)language error:(NSError **)error
{
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    Prism *prism = [Prism new];
    
    return [prism tokenizeString:content language:language error:NULL];
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
    
    NSArray *localContent = [self tokenizePath:self.localPath
                                      language:language
                                         error:NULL];
    
    NSAttributedString *buffer;
    
    if (self.remotePath) {
        NSArray *remoteContent = [self tokenizePath:self.remotePath
                                           language:language
                                              error:NULL];
        
        NSArray <Patch*> *patches = [localContent longestCommonSubsequence:remoteContent];
        
        if (self.debugButton.state == NSControlStateValueOn) {
            NSMutableArray *filteredPatches = NSMutableArray.new;
            for (Patch*patch in patches)
            {
                if ([patch.left isEqual:patch.right]) {
                    [filteredPatches addObject:patch.left];
                }
                else {
                    [filteredPatches addObject:patch];
                }
            }
            buffer = [JJRSObjectDescription attributedDescriptionForObject:filteredPatches];
        } else {
            buffer = [self attributedStringFromPatches:patches];
        }
    } else {
        if (self.debugButton.state == NSControlStateValueOn) {
            buffer = [JJRSObjectDescription attributedDescriptionForObject:localContent];
        } else {
            buffer = [self attributedStringFromTokens:localContent];
        }
    }
    
    self.currentLanguage = language;
    
    [self.languageButton selectItemWithRepresentedObject:language];
    
    self.textView.backgroundColor = [NSColor colorFromXCColorThemeString:@"0.118 0.125 0.157 1"];
    [self.textView.textStorage setAttributedString:buffer];
}

-(NSAttributedString*)attributedStringFromTokens:(NSArray *)tokens {
    NSMutableAttributedString *buffer = [NSMutableAttributedString new];
    for (id token in tokens)
    {
        NSAttributedString *string = [self attributedStringFromValue:token color:nil];
        [buffer appendAttributedString:string];
    }
    return buffer;
}

-(NSAttributedString*)attributedStringFromPatches:(NSArray <Patch*> *)patches {
    NSMutableAttributedString *buffer = [NSMutableAttributedString new];

    NSMutableAttributedString *leftBuffer = [NSMutableAttributedString new];
    NSMutableAttributedString *rightBuffer = [NSMutableAttributedString new];
    
    for (Patch*patch in patches)
    {
        if ([patch.left isEqual:patch.right])
        {
            NSAttributedString *string = [self attributedStringFromValue:patch.left color:nil];
            [leftBuffer appendAttributedString:string];
            [rightBuffer appendAttributedString:string];
        } else {
            if (patch.left)
            {
                NSAttributedString *string = [self attributedStringFromValue:patch.left color:[NSColor colorFromXCColorThemeString:@"0.16 0.24 0.18 1"]];
                [leftBuffer appendAttributedString:string];
            }
            if (patch.right)
            {
                NSAttributedString *string = [self attributedStringFromValue:patch.right color:[NSColor colorFromXCColorThemeString:@"0.26 0.16 0.17 1"]];
                [rightBuffer appendAttributedString:string];
            }
        }
        
        if ([leftBuffer.string containsString:@"\n"] || [rightBuffer.string containsString:@"\n"] || patch == patches.lastObject) {
            if (![leftBuffer isEqual:rightBuffer])
            {
                [buffer appendAttributedString:rightBuffer];
            }
            [buffer appendAttributedString:leftBuffer];
            leftBuffer = [NSMutableAttributedString new];
            rightBuffer = [NSMutableAttributedString new];
        }
    }
    return buffer;
}

-(NSAttributedString *)attributedStringFromValue:(id)value color:(NSColor*)color
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    attributes[NSBackgroundColorAttributeName] = color;
    
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
