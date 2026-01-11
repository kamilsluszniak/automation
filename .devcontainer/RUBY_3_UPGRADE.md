# Ruby 3.0 Upgrade Guide

## Current Issue

The main blocker for Ruby 3.0 is **minitest 5.14.0**, which has a Ruby version constraint of `~> 2.2` (meaning `>= 2.2.0 and < 3.0.0`), explicitly excluding Ruby 3.0.

## Gems That Need Updating

### Critical (Blocking Ruby 3.0)

1. **minitest** (currently 5.14.0)
   - **Issue**: Requires `~> 2.2` (excludes Ruby 3.0)
   - **Solution**: Update to minitest 5.15.0+ (supports Ruby 3.0)
   - **Available versions**: 5.15.0, 5.16.0, 5.17.0, ... up to 5.27.0, and 6.0.0+
   - **Command**: `bundle update minitest`

### Potentially Affected Gems

These gems may need updates but should be checked:

1. **Rails 6.0.2.2**
   - Rails 6.0 officially supports Ruby 2.5-2.7
   - Rails 6.1+ adds Ruby 3.0 support
   - **Note**: You may need to upgrade to Rails 6.1+ for full Ruby 3.0 support

2. **nokogiri** (currently 1.10.9)
   - Older versions may have issues with Ruby 3.0
   - **Solution**: Update to latest 1.x or 1.13+ for better Ruby 3.0 support

3. **pg** (currently 1.2.3)
   - Should work with Ruby 3.0, but newer versions recommended
   - **Solution**: Update to latest 1.x

4. **puma** (currently 3.12.4)
   - Older versions may have compatibility issues
   - **Solution**: Update to 3.x latest or consider 4.x

5. **devise** (currently 4.7.1)
   - Should work, but newer versions have better Ruby 3.0 support
   - **Solution**: Update to latest 4.x

6. **therubyracer** (currently 0.12.3)
   - This gem is deprecated and may have issues with Ruby 3.0
   - **Consider**: Replacing with `mini_racer` or removing if not needed

## Recommended Upgrade Steps

### Option 1: Minimal Update (Just Fix Blockers)

```bash
# Update minitest to support Ruby 3.0
bundle update minitest

# Update Gemfile.lock
bundle install
```

### Option 2: Comprehensive Update (Recommended)

```bash
# Update all gems to latest compatible versions
bundle update

# Or update specific gems
bundle update minitest nokogiri pg puma devise
```

### Option 3: Rails Upgrade Path (For Full Ruby 3.0 Support)

If you want full Ruby 3.0 support, consider upgrading Rails:

```bash
# Update Rails to 6.1+ (supports Ruby 3.0)
bundle update rails

# This will update many dependencies
bundle install
```

## Testing After Upgrade

After updating gems:

1. **Run tests**: `bundle exec rspec`
2. **Check for deprecation warnings**: Ruby 3.0 has some breaking changes
3. **Update code if needed**: Some keyword argument handling changed in Ruby 3.0

## Ruby 3.0 Breaking Changes to Watch For

1. **Keyword Arguments**: Ruby 3.0 separates positional and keyword arguments
2. **Pattern Matching**: New syntax (usually not breaking)
3. **Deprecations**: Some methods deprecated in 2.7 are removed in 3.0

## Current Status

- **Ruby 2.7.8**: ✅ Works (current devcontainer setup)
- **Ruby 3.0**: ❌ Blocked by minitest 5.14.0
- **Ruby 3.1+**: ❌ Would require Rails 6.1+ and more gem updates

## Quick Fix for Ruby 3.0

If you want to try Ruby 3.0 quickly:

```bash
# In your Gemfile, you could temporarily override minitest
# (though updating is better)
bundle update minitest

# Then update Dockerfile to use ruby:3.0
```

## Notes

- Ruby 2.7.8 is still supported and works well with Rails 6.0
- Ruby 3.0 reached EOL in March 2024, but is still widely used
- For production, consider staying on 2.7.8 or upgrading to Rails 6.1+ with Ruby 3.1+
