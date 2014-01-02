#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNAnnotationType) {
  MNAnnotationTypeNone,
  MNAnnotationTypeAllDay,
  MNAnnotationTypeMultiDayStart,
  MNAnnotationTypeMultiDayMiddle,
  MNAnnotationTypeMultiDayEnd
};

@interface MNAnnotation : NSObject
@property (nonatomic, assign) MNAnnotationType type;
@property (nonatomic, strong) UIColor *color;
+ (MNAnnotation *)annotationOfType:(MNAnnotationType)type andColor:(UIColor *)color;
@end
