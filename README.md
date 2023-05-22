# Symmetric Cryptography (AES256 +GCM)
We share with the community an exceeding high throughput 256-bit AES cipher.
It works with 256-bit keys, only.
This is because even under an attack by a quantum algorithm,
the number of remaining security bits of a 256-bit key still provides extremely high security.

As opposed to some other existing designs that use lookup tables to perform byte substitution,
our AES works directly based on [A Very Compact S-Box for AES by D. Canright](https://link.springer.com/chapter/10.1007/11545262_32).
The isomorphism bit matrices are optimized which helps significantly with area-limited hardware implementations.
Also, having the s-box as circuitry, as opposed to memory, saves a lot of energy by omitting the need for memory fetches.

AES itself is implemented based on the methodology suggested by [Fast AES Implementation:
A High-throughput Bitsliced Approach](https://ieeexplore.ieee.org/document/8691582).
In here, byte-wise operations are performed through register shift and swapping, saving energy.
Also, shift-rows stage is implicitly handled through input rearrangement, again saving time and energy.

Our AES works under `GCM` which is the most secure mode of operation known to date.
The `GCM` implementation also comes with secure data authentication capability.