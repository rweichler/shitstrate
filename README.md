# Shitstrate

This is mostly for my reference, but this demonstrates why assembly is necessary in MobileSubstrate, even with hooking Objective C.

> &lt;rpetrich&gt; rweichler: the problems are around calling through to the "original" method implementation
> 
> &lt;rpetrich&gt; rweichler: imagine you have classes Foo and Bar, where Bar is a subclass of Foo
> 
> &lt;rpetrich&gt; rweichler: Foo has a -baz method, which isn't overridden on Bar
> 
> &lt;rpetrich&gt; rweichler: your tweak hooks the -baz method on Bar to add its behaviours, and like a good citizen calls through to the original implementation
> 
> &lt;rpetrich&gt; rweichler: later on, my tweak decides it also wants to hook -baz, this time on Foo
> 
> &lt;rpetrich&gt; rweichler: will your call to the original method implementation call my -baz hook?
> 
> &lt;rpetrich&gt; rweichler: if you aren't careful about how you apply the hook on your end, the answer might be no!

The first thing I thought of was, if you don't have an original method, then you just have a dummy original method that just calls the superclass's. Kind of like:

```objc
NSString *generic_original(id self, SEL _cmd)
{
    Class super = class_getSuperclass(self);
    Method m;
    find_method(super, _cmd, &m);
    IMP i = method_getImplementation(m);

    return i(self, _cmd);
}
```

But the problem with that is the arguments can be anything! What do you do if it's something like this?

```objc
-(NSString *)takesArguments(int arg1)
{
    //...
}
```

Then you'd need to make something like:

```objc
NSString *generic_original2(id self, SEL _cmd, int arg1)
{
    ///...
}
```

And that's obviously not very generic and user friendly like MobileSubstrate is. Hence the assembly. Probably as a way to insert that method and have those types of dynamic arguments.
