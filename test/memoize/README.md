# Memoize Command Caching System

A powerful bash command caching system that stores and reuses command outputs to dramatically improve performance for repeated commands.

## Quick Start

```bash
# Cache a command
memoize ls -la

# Clear cache
memoize_clear

# View statistics
memoize_stats
```

## Commands

### memoize
Caches command outputs for faster subsequent executions.

**Usage:** `memoize <command> [arguments...]`

**Parameters:**
- `<command>` - The command to execute and cache (required)
- `[arguments...]` - Any arguments to pass to the command

**Examples:**
```bash
# Cache a simple command
memoize find . -name "*.txt"

# Cache with complex arguments
memoize grep -r "pattern" /path/to/search

# Cache script execution
memoize python myscript.py --verbose
```

### memoize_clear
Clears the command cache.

**Usage:** `memoize_clear [command_family]`

**Parameters:**
- `[command_family]` - Optional command family to clear (e.g., "bash", "python")

**Examples:**
```bash
# Clear entire cache
memoize_clear

# Clear only bash commands
memoize_clear bash
```

### memoize_stats
Displays cache statistics and usage information.

**Usage:** `memoize_stats`

**Parameters:** None required

## Environment Variables

Configure memoize behavior using these environment variables:

- `MEMOIZE_TTL` - Time-to-live for cache entries (default: "1h")
  - Format: `[number][unit]` where unit can be:
    - `s` - seconds
    - `m` - minutes  
    - `h` - hours
    - `d` - days
  - Example: `export MEMOIZE_TTL="30m"` for 30 minute TTL

- `DEBUG` - Enable debug output (set to any value)
  - Example: `export DEBUG=1`

- `MEMOIZE_ENABLE_BACKOFF` - Enable collision avoidance (set to any value)
  - Example: `export MEMOIZE_ENABLE_BACKOFF=1`

## Features

### 🚀 Performance
- Dramatically speeds up repeated commands
- Intelligent caching with configurable TTL
- Concurrent access handling

### 🔧 Reliability  
- Graceful failure handling
- Collision detection and avoidance
- Proper cleanup operations

### 📊 Monitoring
- Detailed statistics tracking
- Cache hit/miss reporting
- Performance metrics

### 🛡️ Safety
- Command family isolation
- Large output handling
- Special character support

## How It Works

1. **Command Hashing**: Each command is hashed to create a unique cache key
2. **Cache Lookup**: Before execution, checks if cached result exists and is valid
3. **Execution**: If no valid cache, executes command and stores result
4. **Return**: Returns cached result or fresh execution output

## Advanced Usage

### Command Families
Commands are grouped by family (e.g., "bash", "python", "find") for organized cache management.

### Concurrent Access
The system handles multiple simultaneous memoize calls safely using file locking and collision detection.

### Large Outputs
Efficiently handles commands with very large outputs (tested up to 10KB+).

## Testing

Comprehensive test suites are included:

```bash
# Run all tests
./run_all_memoize_tests.sh

# Run specific test suites
./test_memoize_basic/testMemoizeBasic.sh
./test_memoize_advanced/testMemoizeAdvanced.sh  
./test_memoize_edge_cases/testMemoizeEdgeCases.sh
```

## Requirements

- Bash 4.0+
- SQLite3
- Standard Unix utilities

## Troubleshooting

### Enable Debug Mode
```bash
export DEBUG=1
memoize your_command
```

### Clear Problematic Cache
```bash
memoize_clear
```

### Check Dependencies
```bash
which sqlite3
```

## License

This project is part of a larger command optimization system.
