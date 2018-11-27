# wafoo

## これなに

* AWS WAF の IPSets をいじるコマンドラインツール
* ツッコミどころが満載です

## Install

Add this line to your application's Gemfile:

```ruby
gem 'wafoo'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install wafoo
```

## Getting Started

### Step 1: Listing IPSets

```sh
$ bundle exec wafoo list
```

### Step 2: Export IPSets details

```sh
$ bundle exec wafoo export --ip-set-id=${IPSet ID}
```

The IP list is exported to the current directory. (The file name is IPSet ID.)

### Step 3: Modify IPSets details

```sh
$ vim ${IPSet ID}
```

### Step 4: Check IP list

Check the IP list before applying.

```sh
$ bundle exec wafoo apply --ip-set-id=${IPSet ID} --dry-run
```

### Step 5: Apply IP list

```sh
$ bundle exec wafoo apply --ip-set-id=${IPSet ID}
```