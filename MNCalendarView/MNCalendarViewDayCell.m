//
//  MNCalendarViewDayCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewDayCell.h"
#import "MNAnnotation.h"
#import "MNCalendarViewDayCell_Private.h"

void MNContextDrawDot(CGContextRef c, CGPoint center, CGFloat radius, CGColorRef color) {
  CGContextSetFillColorWithColor(c, color);
  CGContextAddEllipseInRect(c, CGRectMake(center.x, center.y, radius, radius));
  CGContextFillPath(c);
}

void MNContextDrawLine(CGContextRef c, CGPoint start, CGPoint end, CGColorRef color, CGFloat lineWidth) {
    CGContextSetAllowsAntialiasing(c, false);
    CGContextSetStrokeColorWithColor(c, color);
    CGContextSetLineWidth(c, lineWidth);
    CGContextMoveToPoint(c, start.x, start.y - (lineWidth/2.f));
    CGContextAddLineToPoint(c, end.x, end.y - (lineWidth/2.f));
    CGContextStrokePath(c);
    CGContextSetAllowsAntialiasing(c, true);
}


NSString *const MNCalendarViewDayCellIdentifier = @"MNCalendarViewDayCellIdentifier";

@implementation MNCalendarViewDayCell

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];

    UIColor *textColor;
    UIColor *backgroundColor;
    if (self.psuedoDate) {
        textColor = [UIColor lightGrayColor];
        backgroundColor = [UIColor colorWithWhite:.96f alpha:1.f];
    } else if (!self.enabled) {
        textColor = [UIColor lightGrayColor];
        backgroundColor = [UIColor colorWithWhite:.96f alpha:1.f];
    } else {
        // normal
        textColor = [UIColor darkTextColor];
        backgroundColor = [UIColor whiteColor];
    }

  self.titleLabel.textColor = textColor;
  self.backgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef separatorColor = self.separatorColor.CGColor;
    CGSize size = self.bounds.size;
    CGFloat pixel = 1.f / [UIScreen mainScreen].scale;

    if (self.drawRightSeparator) {
        MNContextDrawLine(context,
                          CGPointMake(size.width - pixel, pixel),
                          CGPointMake(size.width - pixel, size.height),
                          separatorColor,
                          pixel);
    }

  
  if (!self.enabled) {
    return;
  }
  
  
    
//    // draw bottom border
//    MNContextDrawLine(context,
//                      CGPointMake(0.f, self.bounds.size.height),
//                      CGPointMake(self.bounds.size.width, self.bounds.size.height),
//                      separatorColor,
//                      pixel);

    
  if (self.weekday != 7) {
      // draw right line on cells 0-5
    MNContextDrawLine(context,
                      CGPointMake(size.width - pixel, pixel),
                      CGPointMake(size.width - pixel, size.height),
                      separatorColor,
                      pixel);
  }
  
  // draw dots
  const CGFloat kSpacing = 8;
  const CGFloat kCircleRadius = 5;
  CGPoint dotCenter = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
  dotCenter.x -= 3;
  dotCenter.y += 10;
  dotCenter.x -= (self.dotColors.count - 1) * kSpacing/2.0;
  for (UIColor *color in self.dotColors) {
    MNContextDrawDot(context, dotCenter, kCircleRadius, color.CGColor);
    dotCenter.x += kSpacing;
  }
  
  // draw all day annotations
  const CGFloat kLineWidth = 3;
  const CGFloat kLineSpacing = 4;
  const CGFloat kHorizSpacing = 0.1; // start at 20% from each side
  CGFloat lineCenterY = 5;
  for (MNAnnotation *annotation in self.allDayAnnotations) {
      if (annotation.type != MNAnnotationTypeNone) {
    //annotation
    CGPoint start = CGPointMake(CGRectGetWidth(self.bounds)*kHorizSpacing, lineCenterY);
    CGPoint end = CGPointMake(CGRectGetWidth(self.bounds)*(1.0-kHorizSpacing), lineCenterY);
    if (annotation.type == MNAnnotationTypeMultiDayEnd || annotation.type == MNAnnotationTypeMultiDayMiddle) {
      start.x = 0;
    }
    if (annotation.type == MNAnnotationTypeMultiDayStart || annotation.type == MNAnnotationTypeMultiDayMiddle) {
      end.x = CGRectGetWidth(self.bounds);
    }
    
    MNContextDrawLine(context, start, end, annotation.color.CGColor, kLineWidth);
      }
    lineCenterY += kLineSpacing;
  }
}

@end
