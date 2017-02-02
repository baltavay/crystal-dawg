# crystal-dawg

Deterministic acyclic finite state automaton in crystal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-dawg:
    github: baltavay/crystal-dawg
```

## Usage

```crystal
require "crystal-dawg"
```

```crystal
# create dawg
dawg = Dawg.create
# add words in alphabetical order
dawg.add("taps")
dawg.add("tops")
dawg.finish

# query word
dawg.query("t")
-> [taps, tops]

# saving
Dawg.save("dawg.dawg", dawg)

# there is two variants of loading dawg structure
# 1: fast but eats more memory
dawg = Dawg.load("dawg.dawg", Dawg::Type::Fast)
# 2: little memory usage but slower
dawg = Dawg.load("dawg.dawg", Dawg::Type::Small)

```

## Contributing

1. Fork it ( https://github.com/baltavay/crystal-dawg/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
