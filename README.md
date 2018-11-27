# wafoo [![Build Status](https://travis-ci.org/inokappa/wafoo.svg?branch=master)](https://travis-ci.org/inokappa/wafoo) [![Gem Version](https://badge.fury.io/rb/wafoo.svg)](https://badge.fury.io/rb/wafoo)

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

## 準備

とりあえずは, direnv と組み合わせて利用することを想定しており, AWS のクレデンシャル情報は .envrc に記載して下さい.

```sh
export AWS_PROFILE=your-profile
export AWS_REGION=ap-northeast-1
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
