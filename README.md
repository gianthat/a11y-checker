# Accessibility Checker

`a11y-checker.sh` is a bash script that automates the process of checking web page accessibility using IBM's Equal Access Accessibility Checker. This script streamlines the process of scanning multiple URLs, managing output reports, and handling timeouts for non-responsive pages.

## Requirements

- **Node.js (v18 or later)**: The script uses `npx` to execute the accessibility checker, which requires Node.js.
- **IBM Equal Access Accessibility Checker**: A Node.js module used for performing accessibility checks.
- **GNU Core Utilities (timeout command)**: Required for handling command execution timeouts.
- **Bash**: A Unix shell and command language.

### For macOS Users:
- **Homebrew**: A package manager for macOS, used for installing GNU Core Utilities.

## Installation

### Node.js and IBM Equal Access Accessibility Checker

1. **Install Node.js**: If you don't have Node.js installed, use `nvm` (Node Version Manager) to install it. You can find `nvm` installation instructions [here](https://github.com/nvm-sh/nvm#installing-and-updating).

   Once `nvm` is installed, install Node.js (v18 or later) using:
   ```bash
   nvm install 18
   nvm use 18
   ```

2. **Install IBM Equal Access Accessibility Checker**:
   ```bash
   npm install -g accessibility-checker
   ```

### Timeout Command

- **macOS**:
  - Install Homebrew if not already installed:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
  - Install GNU Core Utilities:
    ```bash
    brew install coreutils
    ```
  - Note: On macOS, GNU tools installed via Homebrew have a `g` prefix (e.g., `gtimeout`). You may need to modify the script to use `gtimeout`.

### Bash
- Bash is typically pre-installed on Linux and macOS. No additional installation is required.

## Usage

To use `a11y-checker.sh`, follow these steps:

1. **Download the script**: Clone or download the script from the GitHub repository.

2. **Make the script executable**:
   ```bash
   chmod +x a11y-checker.sh
   ```

3. **Run the script**:
   ```bash
   ./a11y-checker.sh "domain1.com,sub.domain2.com/page,anotherdomain.com"
   ```
   Replace the domain placeholders with actual URLs you want to check.

4. **View the reports**: After the script execution, reports will be generated in the `scans/` directory, organized by domain and date-time.

Great! Let's enhance the README by including the usage instructions for the `-f` flag to specify the output format. I'll append the relevant section for you:

## Additional Usage Options

### Output Format

The `a11y-checker.sh` script supports specifying the output format for the accessibility reports. Use the `-f` flag followed by one of the valid format options: `json`, `csv`, `xlsx`, or `html`. The default format is `html`.

#### Example Usage with Output Format:

```bash
./a11y-checker.sh -f json "domain1.com,sub.domain2.com/page,anotherdomain.com"
```

In this example, the script will generate reports in JSON format.

### Notes on Output Formats:
- **JSON**: Provides a structured data format, useful for further automated processing or analysis.
- **CSV/XLSX**: Ideal for spreadsheet applications, data analysis, and reporting.
- **HTML**: Offers a web-friendly format that is easy to view and navigate.

Remember to replace the domain placeholders with actual URLs you want to check. The reports will be generated in the `scans/` directory, organized by domain and date-time, in the specified format.

## Notes
- The script handles navigation timeouts and moves on to the next URL without manual intervention.
- Ensure that Node.js and GNU Core Utilities are correctly installed and available in your system's PATH.

## Contributions
Contributions to `a11y-checker.sh` are welcome. Feel free to fork the repository, make improvements, and submit pull requests.
