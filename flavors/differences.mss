@make(manual)
@modify(programexample,free on)
@style(singlesided)
@begin(titlepage)
@titlebox{@majorheading(Spice Lisp Flavors)}
@copyrightnotice{
Written by Steven Handerson and Jim Muller as part of the Spice Lisp project.
}
@end(titlepage)

@chapter(Introduction)
Spice Lisp Flavors was written based on a textual description of version 5.0
Zetalisp.  Various modifications have been made to convert Flavors into Common
Lisp, but hopefully code that does not depend on other features of Zetalisp
(such as the window system) will work in Slisp Flavors.

@subheading(Basic Operation)
@index(Cleanup)@index(Dirty Flavors)
Spice Lisp Flavors was deisgned to never lose state.  Any change that affects
other flavors first propogates notice of the change to all the affected
flavors, the "dirty" flavors.  The change is them made, and then a general
"cleanup" procedure is invoked that updates all the dirty flavors.

This has a few important implications.  One useful result is that it's quite
simple to make efficient changes to large Flavors structures; all you have to
do is inhibit cleanup until the changes are finished.  However, various
operations (such as using compiler-compile-flavors) use the cleanup machinery
in order to function, and so must clean up before continuing.

@index(Wrappers)@index(Recompile-flavor)

Slisp Flavors also follows version 5.0 in making recompilation due to wrapper
redefinition automatic.  It does this generally by storing the sxhash of the
wrapper code, and comparing this to the sxhash of the new defwrapper.
@foot(Actually, in interpreted interactions the code is compared with equal
since that's faster, but wrapper code loaded from compiled files only includes
the sxhash).
This will probably detect a change in virtually all of the cases; however, it
is conceivable that the user might enter a different wrapper that hashes to the
same value.  In this case, he will probably have to detect this himself, and
use @t(recompile-flavor) to recalculate the combined method.


@chapter(Additions to Slisp Flavors)

Wrappers and whoppers, in addition to normal methods, can have any type.
However, you must make your own method combinations in order to make use of this.

@begin(description)
@t(*undefined-flavor-names*)@index(*undefined-flavor-names*)@>[Variable]@*
A list of referred-to but not yet defflavored flavors.

@t(*flavor-compile-methods*)@index(*flavor-compile-methods*)@>[Variable]@*
If this is T, newly calculated combined methods are automatically compiled.
Our machine and compiler just isn't as fast as for a 3600.

@t(*dirty-flavors*)@index(*dirty-flavors*)@>[Variable]@*
Holds an array of the dirty flavors.  Please don't alter.

@t(cleanup-all-flavors)@index(Cleanup-all-flavors)@>[Function]@*
If you interrupt a change in progress, you can use this to finish it.

@t(without-cleaning-flavors) &rest @i(forms)@>[Function]@* 
This executes the @i(forms), but recompilation and updating of flavors that
the execution of the @i(forms) may cause is done @i(after) executing them
all.  This is useful if you want to change a bunch of flavors that affect the
same combined methods.

@t(continue-whopper-all)@index(continue-whopper-all)@>[Macro]@*
This form, when executed in a whopper definition, causes the combined method to
be continued with all the arguments received by the whopper.  This form exists
because Common Lisp doesn't have stack &rest args, and we might save a lot of
consing here.

@end(description)


@chapter(Differences between Symbolics and Slisp Flavors)

@begin(itemize)
There is no variant form of defmethod (that takes a function name).
This could be done easily, but it would probably do an extra function
call.

@index(mixtures)@index(flavor-default-init-putprop, etc.)
Mixtures, and @t(flavor-default-init-putprop), etc.
are not yet implemented.

Instances cannot be funcalled.  If they are, it should probably be 
object-specific; i.e., funcalling an object sends a 'funcall message to the
object with the arguments.  

@index(instantiate-flavor)@index(defun-method)@index(defselect-method)
@index(declare-flavor-instance-variables)@index(locate-in-instance)
@index(describe-flavor)@index(*flavor-compilations* special)
@index(*flavor-compile-trace* special)@index(:method-order flavor option)
@index(:special-instance-variables flavor option)
The following things will probably never be implemented:
@t(instantiate-flavor, defun-method, defselect-method
declare-flavor-instance-variables, locate-in-instance, describe-flavor)
forms; @t(*flavor-compilations* and *flavor-compile-trace*) specials; and 
@t(:special-instance-variables and :default-handler) flavor options.
[To make a default handler, handle :unclaimed-message.]

In the Symbolics implementation, any method having a type not used by the
method combination defined for that method signals an error.  This is currently
not done in Slisp Flavors.
@end(itemize)
@begin(description)

@index(continue-whopper)
@t(Continue-whopper) @b(&rest) @i(args) @>[Macro]@*

@index(lexpr-continue-whopper)
@t(Lexpr-continue-whopper) @b(&rest) @i(args) @>[Macro]@*
These are macros in Slisp Flavors, so that the continuation can be called with
extra implementation-dependent arguments.

@index(recompile-flavor)
@t(recompile-flavor) @i(message) @b(&optional) (@i(do-dependents) @b(t)) @>[Function] @*
@i(Message) can be either @b(nil) for all messages, a single message name, or a
list of message names.  Note that the arguments are different.

@index(compile-flavor)@index(compiler-compile-flavors)
@t(compile-flavor) @i(flavor) @>[Function]@*
For use in the interpreter only.  To do the right thing in compiled files,
use compiler-compile-flavors, below.  These are two forms because I couldn't 
think of a way to tell whether one was in the compiler or not.

@index(compiler-compile-flavors)
@t(compiler-compile-flavors) @b(&rest) @i(flavors) @>[Macro]@* 
This is different in a couple of ways from compile-flavor of all of the named
flavors.  @t(Compile-flavor) doesn't recompile anything it can find in the
current environment; @t(compiler-compile-flavors) does, so that it will surely
be there in the loadtime environment.  @t(Compiler-compile-flavors) therefore
also makes sure that each combined methods calculated is only calculated once.

@end(description)
