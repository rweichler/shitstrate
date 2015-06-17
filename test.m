#include <Foundation/Foundation.h>
#include <objc/runtime.h>



static BOOL find_method(Class orig, SEL sel, Method *result) {
    for(Class cls = orig; cls != nil; cls = class_getSuperclass(cls)) {
        unsigned int size;
        Method *methods = class_copyMethodList(cls, &size);
        if(methods == NULL)
            continue;

        for(int i = 0; i != size; i++) {
            Method m = methods[i];
            if(method_getName(m) == sel) {
                free(methods);
                *result = m;
                return cls == orig;
            }
        }

        free(methods);
    }
    *result = nil;
    return false;
}

@interface Foo : NSObject
@end

@implementation Foo
-(NSString *)baz
{
    return @"orig foo";
}
@end

@interface Bar : Foo
@end

@implementation Bar
@end

NSString *hook_foo(Foo *self, SEL _cmd)
{
    return @"hook foo";
}

typedef NSString * (*imp_t)(id, SEL);
imp_t orig_bar;
NSString *hook_bar(Bar *self, SEL _cmd)
{
    return [NSString stringWithFormat:@"%@ '%@'", @"hook bar, super is", orig_bar(self, _cmd)];
}

static BOOL FORCE_SET_IMPL = false;
BOOL hook(Class cls, SEL sel, IMP imp, IMP *orig)
{
    Method method;
    BOOL class_has_method = find_method(cls, sel, &method);

    if(method == nil) {
        fprintf(stderr, "method not found!!!!111!!\n");
        return false;
    }

    if(orig != NULL) {
        *orig = method_getImplementation(method);
    }

    printf("-[%s %s]: %s\n", class_getName(cls), sel_getName(sel), class_has_method ? "HAS method, hooking" : FORCE_SET_IMPL ? "DOES NOT have method, but IGNORING due to flag set" : "DOES NOT have method, adding");

    if(class_has_method || FORCE_SET_IMPL) {
        method_setImplementation(method, imp);
    } else {
        const char *type = method_getTypeEncoding(method);
        return class_addMethod(cls, sel, imp, type);
    }

    return true;
}

void test(Class cls)
{
    const char *result = [[[[cls alloc] init] baz] UTF8String];
    printf("Calling %s: \"%s\"\n", class_getName(cls), result);
}

int main(int argc, char *argv[])
{
    hook(Bar.class, @selector(baz), (IMP)hook_bar, (IMP *)&orig_bar);
    hook(Foo.class, @selector(baz), (IMP)hook_foo, NULL);
    printf("\n\n\n");
    test(Foo.class);
    test(Bar.class);

    return 0;
}
