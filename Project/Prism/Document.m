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

@property (nonatomic, strong) NSString *currentLanguage;

@property (nonatomic, strong) NSDictionary *currentTheme;


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
    
    NSArray *availableLanguages = [[prism availableLanguages] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [self.languageButton removeAllItems];
    for (NSString *availableLanguage in availableLanguages) {
        NSMenuItem *menutItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(availableLanguage, @"")
                                                           action:@selector(selectLanguage:)
                                                    keyEquivalent:@""];
        menutItem.representedObject = availableLanguage;
        [self.languageButton.menu addItem:menutItem];
    }
    [self refreshContent:nil];
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

- (IBAction)refreshContent:(id)sender {
    
    Print(@"Refresh Content");
    
    if (!self.localPath) return;
    
    if (self.remotePath) {
        self.windowForSheet.title = [NSString stringWithFormat:@"%@ ⇄ %@", self.localPath.lastPathComponent, self.remotePath.lastPathComponent];
    }
    
    Prism *prism = [Prism new];
    
    NSString *language = self.currentLanguage;
    
    if (!language) {
        NSArray *suggestedLanguages = [prism suggestedLanguagesForPath:self.localPath];
        language = suggestedLanguages.firstObject;
    }
    
    NSArray *localContent = [prism tokenizePath:self.localPath
                                       language:language
                                          error:NULL];
    
    NSMutableAttributedString *buffer = [NSMutableAttributedString new];
    
    if (self.remotePath) {
        NSArray *remoteContent = [prism tokenizePath:self.remotePath
                                            language:language
                                               error:NULL];
        
        NSArray <Patch*> *patches = [localContent longestCommonSubsequence:remoteContent];
        
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
    } else {
        for (id token in localContent)
        {
            NSAttributedString *string = [self attributedStringFromValue:token color:nil];
            [buffer appendAttributedString:string];
        }
    }
    
    self.currentLanguage = language;
    
    [self.languageButton selectItemWithRepresentedObject:language];
    
    self.textView.backgroundColor = [NSColor colorFromXCColorThemeString:@"0.118 0.125 0.157 1"];
    [self.textView.textStorage setAttributedString:buffer];
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
    [self refreshContent:self];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeProperty:@selector(cliToken) fromObject:self];
    [coder encodeProperty:@selector(localPath) fromObject:self];
    [coder encodeProperty:@selector(remotePath) fromObject:self];
    [coder encodeProperty:@selector(currentLanguage) fromObject:self];
    [super encodeRestorableStateWithCoder:coder];
}

@end