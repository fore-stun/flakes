Note that `<T> where T: Deserialize<'static>` is never what you want. Also `Deserialize<'de> + 'static` is
never what you want. Generally writing `'static` anywhere near
`Deserialize` is a sign of being on the wrong track. Use one of the above
bounds instead.

Also `Deserialize<'de> + 'static` is never what you want. Generally writing
`'static` anywhere near `Deserialize` is a sign of being on the wrong track. Use one
of the above bounds instead.

Generally writing `'static` anywhere near `Deserialize` is a sign of being on the wrong track.
Use one of the above bounds instead.

**It will soon be necessary to enable developer mode to run userscripts via Tampermonkey**.\
Instructions
on how to enable it can be found [here](https://developer.chrome.com/docs/extensions/reference/api/userScripts#developer_mode_for_extension_users).\
This release
includes significant updates for future [Manifest V3 compatibility](https://developer.chrome.com/docs/extensions/migrating/checklist). Please report
any issues [here](/bug).

So I tried regenerating the lock files using `npm install --package-lock-only` but it attempts and fails to build the entire project when I do that? Wtf?

Sway/flat/erect back — Don’t check this until hip width is correct. (Don’t pin back pattern to bra or you won’t be able to tell if you need a sway/flat/erect back alteration.) For sway/flat/ erect back make a tuck at the center back as deep as needed to make the back hem parallel to the floor, tapering to nothing at the side seam.

Test. This isn’t
right. It’s really not
right.
Yikes! I’m truly a bit
perplexed. This is *very* annoying.

Stephen interrupted. “Doctor, I hope you don’t mind if I tell a story.”

Certainly! You can create a zsh script that uses `mpv` to play video slices based on the specified start and end
timestamps. Here’s a short script that accomplishes this:

To mask the very slow writes to QLC flash, the Crucial P3 Plus operates in SLC mode.
When the drive receives data, it writes each flash cell with a 0 or
1.
This write can finish quickly, then, while idle, the Crucial P3 Plus consolidates the data, reading from SLC and writing in QLC mode.

“So the intended answer to this problem was choice B,
3.
However, the motion of the small circle is not in a straight line, but rather around the large circle.
This revolving action around the large circle contributes an extra revolution as circle A rolls around circle B. Thus, the answer to this question should have been 4, not
3.”

---

For people who are not super confident within Futures and pinning (which includes me), here's a 101 guide:

-   As a reminder, the way it works is: you create a `Future`, move it around if you want, then you pin it, then you start polling it.
    If a `Future` implements `Unpin` then you can pin it, poll it, unpin it, move it, pin it again, poll it, unpin it, move it, and so on.
    If a `Future` does not implement `Unpin`, then you need to pin it once and keep it pinned forever.

-   It almost never makes sense to use `Box<dyn Future>` rather than `Pin<Box<dyn Future>>`.
    Use `Box::pin(fut)` rather than `Box::new(fut)`.

-   Returning `-> impl Future + Unpin` from a function is okay-ish, but means that for instance that you can't use `async`/`await` within the function unless you put `Box::pin` around your `async` block (which is an overhead).
    I think it's preferable for the caller (rather than the callee) to decide how the returned `Future` should be pinned.
    By enforcing that `Future` implement `Unpin`, I can totally imagine situations where we end up boxing a future multiple times because of misunderstandings.

-   If you're writing a struct that wraps around a `Future` (e.g. similar to the combinators that are in the `futures` crate), you can use the `pin-utils` crate to safely turn a `Pin<&mut MyStruct>` into a `Pin<&mut FutureThatIsInsideMyStruct>`.
    Don't try too hard though.
    Worst case scenario, just put a `Pin<Box<>>` around the culprit.

-   On that topic: pinning a `Future` doesn't mean you have to turn it into a `Pin<Box<dyn Future>>`.
    It can also be `Pin<Box<F>>` if you know what `F` is.

-   You can pin a `Future` to the stack using `futures::pin_mut!`.
    I've found that particularly useful in the context of `future::select` within `async` blocks.
    This function requires its parameters to be `Unpin`, and that can be solved by passing pinned versions of your futures.

-   Everything above is applicable to `Stream` and `Sink`.
    For `AsyncRead`/`AsyncWrite` it is a bit more debatable.
    Since you generally want to pass around references to `AsyncRead`/`AsyncWrite`-implementing objects so that functions can read/write a bit and then return, it makes sense to me to require `+ Unpin` on them.
    I'm very uncertain about this point.

-   If you write `struct Foo<T>`, the compiler automatically generates `impl<T: Unpin> Unpin for Foo<T>`.
    This means that you sometimes need to manually add `impl<T> Unpin for Foo<T> {}`.
    As long as you’re not using `unsafe` code, it’s never wrong to write this.
    (this problem is similar to when you’re deriving `Clone` on a struct that contains an `Arc<T>`, and the compiler enforces `T: Clone` for no reason).
