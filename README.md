# Shitstrate

A version of the Obj-C MobileSubstrate without the assembly voodoo in order to demonstrate why it's necessary

> <rpetrich> rweichler: the problems are around calling through to the "original" method implementation
> <rpetrich> rweichler: imagine you have classes Foo and Bar, where Bar is a subclass of Foo
> <rpetrich> rweichler: Foo has a -baz method, which isn't overridden on Bar
> <rpetrich> rweichler: your tweak hooks the -baz method on Bar to add its behaviours, and like a good citizen calls through to the original
>             implementation
> <rpetrich> rweichler: later on, my tweak decides it also wants to hook -baz, this time on Foo
> <rpetrich> rweichler: will your call to the original method implementation call my -baz hook?
> <rpetrich> rweichler: if you aren't careful about how you apply the hook on your end, the answer might be no!
