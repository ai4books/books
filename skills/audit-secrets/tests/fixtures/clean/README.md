# Clean fixture

This directory mentions the words *secret* and *key* in prose to tempt a false
positive, but it contains no secret-shaped values. A good scanner raises zero
findings here. Store real credentials in a managed secrets vault, never in the
repository.
