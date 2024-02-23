# AWS Vault
aws-vault is a powerful tool for managing your AWS credentials securely. By using aws-vault, you can avoid accidentally exposing your credentials and have more control over access to your AWS account.

For more information about aws-vault, refer to the [official documentation](https://github.com/99designs/aws-vault).

## Setting up aws-vault to Add Credentials to the Vault

`aws-vault` is a tool that allows you to manage your AWS credentials securely and conveniently by storing them in an encrypted vault. In this guide, we'll learn how to set up `aws-vault` to add your AWS credentials to the vault.

## Installing aws-vault

First, you need to install `aws-vault`. You can install `aws-vault` via Homebrew (on macOS/Linux),  via Chocolatey (on Windows) or via Taskfile (on macOS/Linux):

### macOS/Linux (Homebrew)
```bash
brew install --cask aws-vault
```
### Windows (Chocolatey)
```bash
choco install aws-vault
```

### Configuring aws-vault
**Starting aws-vault**

Start aws-vault by running the command:
```bash
aws-vault add $PROJECT-$ENV
```
