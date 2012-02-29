//
//  NSMutableAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSMutableDictionary+DTRichText.h"

#import "DTTextAttachment.h"
#import <CoreText/CoreText.h>
#import "NSAttributedStringRunDelegates.h"
#import "NSString+HTML.h"

#import "DTCoreTextFontDescriptor.h"
#import "DTCoreTextConstants.h"


@implementation NSMutableAttributedString (DTRichText)

- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
	if (range.location>0)
	{
		NSInteger index = range.location-1;
		
		unichar character = [[self string] characterAtIndex:index];
		
		if (character != '\n')
		{
			needsParagraphBefore = YES;
		}
	}
	
	if (range.location+range.length<[self length])
	{
		NSUInteger index = range.location+range.length;
		
        unichar character = [[self string] characterAtIndex:index];
		
		if (character != '\n')
		{
			needsParagraphAfter = YES;
		}
	}
	
	NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
	
	if (needsParagraphBefore)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	NSMutableDictionary *objectAttributes = [attributes mutableCopy];
	
	// need run delegate for sizing
	CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate((id)attachment);
	[objectAttributes setObject:(__bridge id)embeddedObjectRunDelegate forKey:(id)kCTRunDelegateAttributeName];
	CFRelease(embeddedObjectRunDelegate);
	
	// add attachment
	[objectAttributes setObject:attachment forKey:NSAttachmentAttributeName];
	
	
	NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:UNICODE_OBJECT_PLACEHOLDER attributes:objectAttributes];
	[tmpAttributedString appendAttributedString:tmpStr];
	
	
	if (needsParagraphAfter)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	
	[self replaceCharactersInRange:range withAttributedString:tmpAttributedString];
	
    return [tmpAttributedString length];
}

- (void)toggleBoldInRange:(NSRange)range
{
	// first character determines current boldness
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	CTFontRef currentFont = (__bridge CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *typingFontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	typingFontDescriptor.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	typingFontDescriptor.fontName = nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range)) 
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		CTFontRef currentFont = (__bridge CTFontRef)[attrs objectForKey:(id)kCTFontAttributeName];
		
		if (currentFont)
		{
			DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
			
			// need to replace name with family
			CFStringRef family = CTFontCopyFamilyName(currentFont);
			desc.fontFamily = (__bridge NSString *)family;
			CFRelease(family);
			
			desc.fontName = nil;
			
			desc.boldTrait = !typingFontDescriptor.boldTrait;
			CTFontRef newFont = [desc newMatchingFont];
			[attrs setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
			CFRelease(newFont);
			
			if (attrRange.location < range.location)
			{
				attrRange.length -= (range.location - attrRange.location);
				attrRange.location = range.location;
			}
			
			if (NSMaxRange(attrRange)>NSMaxRange(range))
			{
				attrRange.length = NSMaxRange(range) - attrRange.location;
			}
			
			[self setAttributes:attrs range:attrRange];
		}
		
        index += attrRange.length;
    }
}


- (void)toggleItalicInRange:(NSRange)range
{
	// first character determines current italic status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	CTFontRef currentFont = (__bridge CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *typingFontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	typingFontDescriptor.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	typingFontDescriptor.fontName = nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range)) 
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		CTFontRef currentFont = (__bridge CTFontRef)[attrs objectForKey:(id)kCTFontAttributeName];
		
		if (currentFont)
		{
			DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
			
			// need to replace name with family
			CFStringRef family = CTFontCopyFamilyName(currentFont);
			desc.fontFamily = (__bridge NSString *)family;
			CFRelease(family);
			
			desc.fontName = nil;
			
			desc.italicTrait = !typingFontDescriptor.italicTrait;
			CTFontRef newFont = [desc newMatchingFont];
			[attrs setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
			CFRelease(newFont);
			
			if (attrRange.location < range.location)
			{
				attrRange.length -= (range.location - attrRange.location);
				attrRange.location = range.location;
			}
			
			if (NSMaxRange(attrRange)>NSMaxRange(range))
			{
				attrRange.length = NSMaxRange(range) - attrRange.location;
			}
			
			[self setAttributes:attrs range:attrRange];
		}
		
        index += attrRange.length;
    }
}

- (void)toggleUnderlineInRange:(NSRange)range
{
	// first character determines current italic status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	BOOL isUnderline = [currentAttributes objectForKey:(id)kCTUnderlineStyleAttributeName]!=nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range)) 
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		
		if (isUnderline)
		{
			[attrs removeObjectForKey:(id)kCTUnderlineStyleAttributeName];
		}
		else
		{
			[attrs setObject:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
		}
		if (attrRange.location < range.location)
		{
			attrRange.length -= (range.location - attrRange.location);
			attrRange.location = range.location;
		}
		
		if (NSMaxRange(attrRange)>NSMaxRange(range))
		{
			attrRange.length = NSMaxRange(range) - attrRange.location;
		}
		
		[self setAttributes:attrs range:attrRange];
		
        index += attrRange.length;
    }	
}

@end