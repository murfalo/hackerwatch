# Hero of Hackerwatch

Modified Heroes of Hammerwatch (HoH) to enable client side alterations without needing to mark profiles as modded.

## Method

Normally when the client assets are modified, HoH outputs a message indicating that the assets package is incorrect and shuts down.  `GDB`'s `break syscall write` command was used to break when this message was written.  The backtrace was then examined, and breakpoints were placed on each of the branches.

Each of these locations were examined in order of most recent to least recent to find branches in the code that might be altered to circumvent the codepath that leads to printing this message.

Once the critical branch was located, `xxd`, `readelf`, and `llvm-objdump` were used to examine and flip the condition for this branch.  In this case, `jne` (`0x0F85`) was switched to `je` (`0X0F84`).

Afterwards, HoH output another message: "Tampering detected".  The above process was simply repeated again, and voila!

See `method.txt` for the full example.

## Notes

For some reason, the addresses in the `xxd` hexdump are shifted relative to the addresses seen in `objdump` and `readelf`.  The outputted hex from `readelf` can be used to search the `xxd` hexdump to find the correct address.

Only the modified scripts are kept in the repo.  The other resource files and the original packed assets file are much too large and aren't modified.

`packager.sh` requires hard paths for arguments.

## Useful commands

1. `objdump -D <exe> ><exe>.obj`
2. `xxd <exe> ><exe>.hex`
3. `xxd -r <exe>.hex ><exe>`
4. `readelf -S <exe>` (to acquire `<sections>`)
5. `readelf -x <section> <exe>`
6. `packager.sh -r <unpacked_resources>`
7. `packager.sh -u <packed_resources> -d <unpacked_resources`

