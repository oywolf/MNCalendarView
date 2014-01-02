#import "MNAnnotation.h"

@implementation MNAnnotation
+ (MNAnnotation *)annotationOfType:(MNAnnotationType)type andColor:(UIColor *)color {
  MNAnnotation *annotation = [[MNAnnotation alloc] init];
  annotation.type = type;
  annotation.color = color;
  return annotation;
}
@end
