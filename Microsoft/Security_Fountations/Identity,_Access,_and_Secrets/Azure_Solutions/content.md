# Introduction

AI applications require secure, centralized credential management to protect API keys, connection strings, and encryption keys across development, staging, and production environments. This module guides you through using Azure Key Vault to store, retrieve, and manage secrets in AI solutions on Azure.

Imagine you're a developer building a RAG pipeline that connects to multiple backend services. The pipeline calls an Azure OpenAI endpoint for embeddings generation, reads from an Azure Cosmos DB vector store, and writes processed results to Azure Blob Storage. Each service requires its own credentials, and those credentials differ across development, staging, and production environments. Today, the team stores connection strings in environment variables and configuration files checked into source control. A recent security audit flagged this practice as a risk because credentials are visible to anyone with repository access, and rotating a compromised key requires redeploying every service that uses it. The client expects credential rotation within four hours of a suspected compromise, with zero downtime during the rotation window. Your team needs a centralized secrets store that controls access through identity-based permissions, tracks every secret access in audit logs, and supports versioned secrets so applications can transition to new credentials without interruption. Caching secrets locally also matters because the pipeline processes thousands of documents per hour, and calling a remote vault for every operation adds unacceptable latency. Azure Key Vault provides the secure storage, versioning, rotation support, and SDK integration that this architecture requires.

After completing this module, you'll be able to:

Explain how Azure Key Vault stores and organizes secrets, keys, and certificates, and identify when to use each object type in an AI solution.
Retrieve secrets programmatically using Azure SDK client libraries with managed identity authentication.
Handle secret versioning and rotation in application code to support zero-downtime credential updates.
Implement caching strategies that reduce Key Vault API calls while maintaining security and freshness guarantees.

> Note
> All code examples in this module are based on the most recent version of the azure-keyvault-secrets library at the time of writing. The library is updated often and the recommendation is to visit the Azure Key Vault secrets client library for Python for the most up-to-date information.

## Store and organize secrets, keys, and certificates

Azure Key Vault is a cloud-hosted service that provides centralized storage and management for sensitive data such as API keys, connection strings, encryption keys, and TLS certificates. AI solutions on Azure handle credentials across every layer of their architecture. A RAG pipeline, for example, might store an Azure OpenAI API key, a Cosmos DB connection string, a storage account key, and a TLS certificate for its public endpoint. Azure Key Vault gives developers a single, secure location to store all of these credentials and retrieve them at runtime through SDK calls, without embedding secrets in application code or configuration files.

### Understand Key Vault capabilities and service tiers

Azure Key Vault provides three core capabilities: secrets management, key management, and certificate management. Each capability addresses a different type of sensitive data, and understanding the distinctions helps you choose the right object type for each credential in your AI application. Key Vault encrypts all stored objects at rest and controls access through Microsoft Entra ID authentication combined with Azure role-based access control (RBAC) authorization.

Key Vault operates in two service tiers that determine how cryptographic keys are protected:

**Standard tier**: Encrypts keys using software libraries validated to FIPS 140 Level 1. This tier is suitable for most application scenarios where software-protected keys provide sufficient security.
**Premium tier**: Protects keys using FIPS 140-3 Level 3 validated hardware security modules (HSMs). Key material never leaves the HSM boundary. You can choose this tier when regulatory or compliance requirements mandate HSM-protected keys.

> Note
> Key Vault tiers, features, and pricing change regularly. For the latest details, see Key Vault pricing.

Developers interact with Key Vault through REST APIs, Azure SDKs (available for Python, .NET, Java, JavaScript, and Go), the Azure CLI, and the Azure portal. The Python SDK is the primary client library used throughout this module.

### Choose the right object type for your credentials

Key Vault stores three object types: secrets, keys, and certificates. Each type serves a distinct purpose, and AI applications often use all three. Selecting the correct object type ensures that your credentials benefit from the appropriate storage, access control, and lifecycle management features.

**Secrets** store arbitrary string values up to 25 KB, such as API keys, connection strings, passwords, and tokens. AI applications use secrets for model endpoint keys, database credentials, and third-party service tokens. Key Vault treats secret values as opaque byte sequences and doesn't enforce any particular structure on the stored data. You can set a `content_type` property (up to 255 characters) to help consumers interpret the value. For example, a `content_type` of `text/plain` signals a simple string, while `application/json` indicates a structured JSON payload.

```python
# Code fragment - focus on setting a secret with content_type
client.set_secret(
    "openai-api-key",
    "sk-abc123def456",
    content_type="text/plain",
    tags={"environment": "production", "team": "ai-platform"}
)
```

**Keys** store cryptographic keys for encryption, signing, and key wrapping operations. Key Vault performs cryptographic operations server-side, so the key material never leaves the vault boundary. AI pipelines that encrypt training data at rest or sign model artifacts use Key Vault keys. Keys support RSA (2048, 3072, and 4096 bit), elliptic curve (P-256, P-256K, P-384, P-521), and symmetric (oct) key types. Because the vault performs the cryptographic operations rather than exposing raw key material, you get stronger security guarantees than managing key files locally.

**Certificates** store and manage X.509 certificates along with their private keys. Key Vault handles certificate lifecycle operations including issuance, renewal, and revocation through integration with certificate authorities. AI services that expose HTTPS endpoints or use mutual TLS for service-to-service authentication benefit from certificate management in Key Vault. When Key Vault stores a certificate, it creates a corresponding key and secret object that you can access through the key and secret APIs respectively.

### Organize vaults and objects for AI solutions

A well-organized vault structure simplifies secret management as your AI application scales across environments and teams. Key Vault doesn't restrict the number of secrets, keys, or certificates you can store in a single vault, but organizing objects with clear boundaries reduces security risk and operational complexity.

**Vault-per-application boundary**: You can create separate vaults for each application and environment combination. For example, a RAG pipeline might use `kv-ragpipeline-dev`, `kv-ragpipeline-staging`, and `kv-ragpipeline-prod`. This separation limits the blast radius of a security incident. A compromised vault exposes only the secrets for one application in one environment. Vault-per-application boundaries also simplify RBAC assignments because you can grant a development team access to the development vault without exposing production credentials.

**Naming conventions**: You can use descriptive, hyphenated names that encode the resource type and purpose. Examples include `cosmosdb-connection-string`, `openai-api-key`, and `blob-storage-account-key`. Consistent naming simplifies programmatic lookups and reduces errors when referencing secrets in code. Vault names themselves must be globally unique within Azure, three to 24 characters long, and contain only alphanumeric characters and hyphens. Vault names must begin with a letter, end with a letter or digit, and can't contain consecutive hyphens.

**Tags for metadata**: You can attach tags to secrets for filtering and management. Each secret supports up to 15 tags, with tag names limited to 512 characters and values limited to 256 characters. Tags like `environment=production`, `team=ai-platform`, and `rotation-policy=90-days` enable bulk operations and reporting across large numbers of vault objects. Anyone with `list` or `get` permission on secrets can read tags, so don't store sensitive data in tag values.

### Control access with Azure RBAC

Azure Key Vault supports two authorization models: Azure RBAC and legacy access policies. Azure RBAC is the recommended approach because it provides granular permission control at the Azure resource level, supports Privileged Identity Management (PIM) for just-in-time access, and works consistently across both the control plane (vault management) and the data plane (secret, key, and certificate operations).

Key Vault defines several built-in data plane roles that map to common access patterns. The following roles are the most relevant for secret management in AI applications:

**Key Vault Secrets User**: Grants read-only access to secret values, including the ability to read certificate private keys stored as secrets. Assign this role to application managed identities that need to retrieve credentials at runtime.
**Key Vault Secrets Officer**: Grants full management permissions on secrets, including create, update, delete, and list operations. Assign this role to operators or CI/CD pipelines responsible for secret lifecycle management.
**Key Vault Administrator**: Grants all data plane operations on keys, secrets, and certificates. This role doesn't grant control plane permissions to manage the vault resource itself or modify role assignments.
**Key Vault Reader**: Grants read access to vault metadata (such as secret names and properties) without revealing secret values or key material. Useful for monitoring and discovery tools that need to verify which secrets exist without accessing their contents.

You can use managed identities for application-to-vault authentication. A managed identity eliminates the need to store any credential in your application code or configuration. The application authenticates to Key Vault through Microsoft Entra ID, and the RBAC role assignment determines what operations the identity can perform. This pattern means your application needs zero stored credentials to access the vault that holds all of its other credentials.

> Important
> The `Key Vault Contributor` role is a control plane role only. It grants permissions to manage the vault resource (create, delete, update vault properties) but doesn't grant access to data plane operations such as reading secrets, keys, or certificates. Always use the data plane roles listed previously for secret access.

### Protect against accidental deletion with soft delete and purge protection

Key Vault enables soft delete by default on all new vaults, and you can't disable it once enabled. When you delete a secret, key, or certificate, Key Vault retains the object in a deleted state for a configurable retention period between seven and 90 days (the default is 90 days). You set the retention period at vault creation, and you can't change it afterward. During the retention window, you can recover deleted objects to their previous state.

Purge protection is an optional feature that prevents permanent deletion of soft-deleted objects during the retention period. When purge protection is enabled, no one can permanently remove a secret until the retention period expires. Purge protection is especially important for AI solutions where losing an encryption key or certificate can render stored data permanently inaccessible. Consider enabling purge protection on production vaults to guard against both accidental and malicious data loss.

When a Key Vault itself is soft-deleted, its RBAC role assignments and Event Grid subscriptions are also deleted. These resources aren't automatically restored when you recover the vault, so you need to recreate them manually after recovery.

### Additional resources

[About Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
[About Azure Key Vault secrets](https://learn.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)
[Azure RBAC for Key Vault data plane operations](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)

## Retrieve secrets using Azure SDK client libraries

The Python `azure-keyvault-secrets` library provides the `SecretClient` class for all secret operations against Azure Key Vault. Combined with the `azure-identity` library for authentication, these two packages give your AI application everything it needs to retrieve credentials at runtime without storing any vault credentials in code. This unit walks through client setup, secret retrieval, listing operations, error handling, and async patterns for high-throughput AI services.

> Note
> All code examples in this unit are patterns to adapt to your application's architecture. The azure-keyvault-secrets library requires Python 3.9 or later and is updated regularly. Visit the Azure Key Vault secrets client library for Python for the most current API reference.

### Install and configure the SDK

The Key Vault secrets SDK requires two packages: `azure-keyvault-secrets` for vault operations and `azure-identity` for authentication. You install both packages together because every `SecretClient` instance requires a credential object to authenticate with Key Vault. The `SecretClient` class provides all CRUD and listing operations for secrets, and you initialize it with the vault URL and a credential.

```bash
pip install azure-keyvault-secrets azure-identity
```

The vault URL follows the pattern `https://<vault-name>.vault.azure.net/`. You can find this URL in the Azure portal on the vault's overview page, or retrieve it with the Azure CLI using `az keyvault show --name <vault-name> --query properties.vaultUri`.

### Authenticate with DefaultAzureCredential

`DefaultAzureCredential` from the `azure-identity` library chains multiple authentication methods in a defined order, trying each one until authentication succeeds. This single credential class works across development and production environments without code changes. In production, managed identity authenticates the application without any stored credentials. In local development, the Azure CLI or Azure Developer CLI credential provides access.

The authentication chain follows this order:

**EnvironmentCredential**: Reads `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_CLIENT_SECRET` environment variables for service principal authentication.
**WorkloadIdentityCredential**: Authenticates using Kubernetes workload identity tokens.
**ManagedIdentityCredential**: Uses the Azure managed identity (system-assigned or user-assigned) attached to the compute resource.
**AzureCliCredential**: Authenticates using the account from `az login`.
**AzureDeveloperCliCredential**: Authenticates using the account from `azd auth login`.
**AzurePowerShellCredential**: Authenticates using the account from `Connect-AzAccount`.

For deployed AI services running on Azure compute resources (such as Azure Container Apps, Azure Kubernetes Service, or Azure App Service), managed identity is the recommended authentication method. The application authenticates to Key Vault through Microsoft Entra ID without any stored credentials. You assign the `Key Vault Secrets User` role to the managed identity, and the application gains read access to secrets in the vault.

### Retrieve a secret by name

The `get_secret()` method retrieves the current version of a secret from Key Vault. The returned `KeyVaultSecret` object contains the secret value, name, and a `properties` object with metadata such as version, creation date, expiration date, enabled status, content type, and tags. Retrieving a single secret is the most common operation in AI application code because your services call it at startup or on-demand to load credentials for downstream services.

```python
# Code fragment - focus on retrieving a secret with DefaultAzureCredential
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(
    vault_url="https://kv-ragpipeline-prod.vault.azure.net/",
    credential=credential
)

secret = client.get_secret("openai-api-key")

# Access the secret value and metadata
api_key = secret.value
version = secret.properties.version
created = secret.properties.created_on
content_type = secret.properties.content_type
```

The `secret.value` property contains the secret string that your application passes to downstream service clients. The `properties` object provides metadata for logging and debugging. You can log the secret name and version for audit purposes without exposing the actual secret value.

### List secret properties

The `list_properties_of_secrets()` method enumerates all secrets in the vault without retrieving their values. This operation returns `SecretProperties` objects that contain metadata such as name, version, content type, tags, and enabled status. You can use this method to discover available secrets, build configuration maps at startup, or verify that expected secrets exist before your application begins processing requests.

```python
# Code fragment - focus on listing secret properties for discovery
secret_properties = client.list_properties_of_secrets()

for prop in secret_properties:
    print(f"Secret: {prop.name}, Enabled: {prop.enabled}, "
          f"Content type: {prop.content_type}")
    if prop.tags:
        print(f"  Tags: {prop.tags}")
```

This listing operation is useful during application startup to validate that all required credentials exist in the vault. If your AI service needs five specific secrets (such as an API key, a database connection string, and three service tokens), you can check for their existence before attempting to retrieve values. This approach surfaces configuration errors early rather than failing on the first request that needs a missing credential.

### Handle errors and exceptions

The SDK raises specific exception types for different failure scenarios, and your application should handle each type differently. A missing secret indicates a configuration error that requires operator intervention, while a transient network error warrants a retry. Distinguishing between these cases in your error handling logic prevents your application from retrying errors that won't resolve on their own and helps operators diagnose issues faster.

```python
# Code fragment - focus on structured error handling for secret retrieval
from azure.core.exceptions import (
    ResourceNotFoundError,
    HttpResponseError,
    ServiceRequestError
)

def get_secret_safely(client, secret_name):
    try:
        secret = client.get_secret(secret_name)
        return secret.value
    except ResourceNotFoundError:
        # Secret doesn't exist - configuration error
        print(f"Secret '{secret_name}' not found in vault. "
              "Verify the secret name and vault configuration.")
        raise
    except HttpResponseError as e:
        # Authentication or authorization failure
        print(f"Access denied or server error for '{secret_name}': "
              f"{e.status_code} - {e.message}")
        raise
    except ServiceRequestError:
        # Network connectivity issue - may be transient
        print(f"Network error retrieving '{secret_name}'. "
              "Check connectivity to Key Vault.")
        raise
```

`ResourceNotFoundError` fires when the secret name doesn't exist in the vault. `HttpResponseError` covers authentication failures (the identity lacks the required RBAC role), authorization errors, and server-side issues. `ServiceRequestError` indicates a network-level problem, such as DNS resolution failure or a timeout, which might resolve on retry.

### Use the async client for high-throughput applications

The azure.keyvault.secrets.aio module provides an async SecretClient for applications that use asyncio. AI services that process concurrent requests benefit from async secret retrieval because it avoids blocking the event loop during vault calls. The async client exposes the same API surface as the synchronous client, so you can switch between them without changing your application logic.

```python
# Code fragment - focus on async secret retrieval
from azure.identity.aio import DefaultAzureCredential
from azure.keyvault.secrets.aio import SecretClient

async def get_ai_credentials():
    credential = DefaultAzureCredential()
    client = SecretClient(
        vault_url="https://kv-ragpipeline-prod.vault.azure.net/",
        credential=credential
    )

    async with client:
        secret = await client.get_secret("openai-api-key")

    await credential.close()
    return secret.value
```

The async client and credential are both async context managers. You should use `async with` or explicitly call `await client.close()` and `await credential.close()` when you're done with them. In web frameworks like FastAPI or aiohttp, create the client once at application startup and reuse it across requests to avoid the overhead of creating new connections for each operation.

### Additional resources

[Azure Key Vault secrets client library for Python](https://learn.microsoft.com/en-us/python/api/overview/azure/keyvault-secrets-readme)
[DefaultAzureCredential overview](https://learn.microsoft.com/en-us/python/api/overview/azure/identity-readme#defaultazurecredential)
[Key Vault developer's guide](https://learn.microsoft.com/en-us/azure/key-vault/general/developers-guide)

## Handle secret versioning and rotation

Every time you store a secret with the same name in Azure Key Vault, the vault creates a new version rather than overwriting the existing value. This versioning model is fundamental to supporting credential rotation in AI applications because it allows old and new credentials to coexist during a transition window. Developers need to understand how versioning works, what rotation strategies are available, and how to write application code that handles credential transitions without downtime.

### Understand how Key Vault versions secrets

Every call to `set_secret()` with the same secret name creates a new version and assigns it a unique version identifier (a GUID string). The `get_secret()` call without a version parameter always returns the latest enabled version. You can also call `get_secret()` with a specific version identifier to retrieve that exact version regardless of whether newer versions exist. Previous versions remain accessible until you explicitly disable or delete them.

```python
# Code fragment - focus on creating a new version and retrieving by version ID
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(
    vault_url="https://kv-ragpipeline-prod.vault.azure.net/",
    credential=credential
)

# Create initial version
initial = client.set_secret("cosmosdb-connection-string", "AccountEndpoint=https://...")
print(f"Version 1: {initial.properties.version}")

# Create new version with updated value
updated = client.set_secret("cosmosdb-connection-string", "AccountEndpoint=https://new...")
print(f"Version 2: {updated.properties.version}")

# Retrieve latest version (returns version 2)
latest = client.get_secret("cosmosdb-connection-string")

# Retrieve specific version (returns version 1)
specific = client.get_secret("cosmosdb-connection-string",
                              version=initial.properties.version)
```

This versioning behavior means your applications don't need to know version identifiers in advance. By default, `get_secret()` returns the latest version, so storing a new version and having the application refetch the secret is enough to complete a rotation. Version identifiers become important when you need to audit which credential version was in use at a specific time or when you need to roll back to a previous version.

### List and inspect secret versions

The `list_properties_of_secret_versions()` method enumerates all versions of a specific secret. Each version entry includes the version identifier, creation date, expiration date, and enabled status. This operation is useful for auditing rotation history, verifying that a rotation occurred successfully, and identifying older versions that should be disabled to prevent continued use after rotation.

```python
# Code fragment - focus on listing and inspecting secret versions
versions = client.list_properties_of_secret_versions("cosmosdb-connection-string")

for version in versions:
    print(f"Version: {version.version}")
    print(f"  Created: {version.created_on}")
    print(f"  Enabled: {version.enabled}")
    print(f"  Expires: {version.expires_on}")
```

After a successful rotation, consider disabling previous versions to enforce that all application instances use the new credential. You can disable a version by calling `update_secret_properties()` with `enabled=False`, which prevents the version from being retrieved even if an application references it by version identifier.

### Choose a rotation strategy

Credential rotation is the process of replacing an active credential with a new one. The right rotation strategy depends on the target service, your team's operational maturity, and how quickly you need to respond to a compromised credential. AI applications typically manage credentials for multiple downstream services, and each service might use a different rotation approach.

**Manual rotation** is the simplest approach. A human operator or CI/CD pipeline creates a new secret version in Key Vault and then restarts or signals the application to pick up the new value. This strategy works well for services that change credentials infrequently, such as a third-party AI model provider that issues long-lived API keys. The downside is that there's a window between when the new secret is stored and when the application restarts to pick it up. During that window, the application still uses the old credential.

**Automated rotation with Event Grid** removes the human step from the rotation process. Key Vault integrates with Azure Event Grid to emit events when secrets approach their expiration date. The `SecretNearExpiry` event fires thirty days before a secret's expiration date, and the `SecretExpired` event fires when the current version's expiration date passes. An Azure Function or other event handler listens for these events, generates a new credential with the target service, and stores the new value as a new secret version in Key Vault. This pattern automates the entire rotation lifecycle. The automated rotation flow works as follows:

Key Vault emits a `SecretNearExpiry` event.
Event Grid delivers the notification to a registered handler.
An Azure Function receives the event.
The function generates a new credential with the target service.
The function stores the new credential as a new secret version in Key Vault.

**Dual-credential** rotation addresses services that support two active keys simultaneously, such as Azure Storage accounts and Azure Cosmos DB. The rotation process follows these steps:

Generate a new secondary key on the target service.
Store the new key as a new secret version in Key Vault.
Wait for all application instances to pick up the new value.
Regenerate the old primary key on the target service.

This two-phase approach guarantees that at least one valid credential always exists. No application instance experiences an authentication failure during the rotation window because the old credential remains valid until every instance transitions to the new one.

### Implement zero-downtime rotation in application code

Regardless of which rotation strategy you choose, your application code must handle the transition between old and new credentials gracefully. The recommended pattern catches authentication failures from downstream services, refetches the secret from Key Vault (which returns the latest version), and retries the operation with the new credential. This approach avoids hard restarts and supports rotation at any time without coordination between the operator and the running application.

```python
# Code fragment - focus on retry-on-auth-failure pattern for rotation
from azure.core.exceptions import HttpResponseError

def call_downstream_service(client, secret_name, max_retries=1):
    """Retrieve secret and call service, refreshing on auth failure."""
    secret_value = client.get_secret(secret_name).value

    for attempt in range(max_retries + 1):
        try:
            # Use secret_value to authenticate with downstream service
            result = connect_to_service(secret_value)
            return result
        except AuthenticationError:
            if attempt < max_retries:
                # Credential might be rotated - refresh from Key Vault
                secret_value = client.get_secret(secret_name).value
            else:
                raise
```

This pattern limits the performance impact of rotation to a single extra Key Vault call when the first authentication attempt fails. During normal operation, the application uses the cached credential without calling Key Vault. The retry only triggers when the downstream service rejects the credential, which signals that a rotation did occur and the application needs to retrieve the updated value.

### Set expiration dates on secrets

The `expires_on` property defines an expiration date when you create or update a secret. Expired secrets still exist in Key Vault and can be retrieved through `get_secret()`, so expiration is informational rather than a hard access block. The expiration date signals to applications and monitoring systems that the credential is stale and should be replaced. Combining expiration dates with Event Grid notifications creates an automated workflow that triggers rotation before a secret expires.

```python
# Code fragment - focus on setting expiration when creating a secret
from datetime import datetime, timezone, timedelta

expiration_date = datetime.now(timezone.utc) + timedelta(days=90)

client.set_secret(
    "openai-api-key",
    "sk-newkey789",
    expires_on=expiration_date,
    content_type="text/plain",
    tags={"rotation-policy": "90-days", "service": "azure-openai"}
)
```

A common pattern for AI applications is to set a ninety-day expiration on API keys and subscribe to the `SecretNearExpiry` event through Event Grid. The event fires thirty days before expiration, giving your rotation automation or operations team a thirty-day window to generate and store a new credential. This approach prevents expired credentials from causing unexpected failures in production.

### Additional resources

[Automate secret rotation for resources with two sets of authentication credentials](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation-dual)
[Monitoring Key Vault with Azure Event Grid](https://learn.microsoft.com/en-us/azure/key-vault/general/event-grid-overview)
[Understanding autorotation in Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/autorotation)

## Implement caching strategies to reduce Key Vault calls

AI applications that process high volumes of requests can't afford the latency of a remote vault call for every operation. An AI inference service handling hundreds of requests per second would quickly exhaust Key Vault's throttling limits and introduce unnecessary latency if it retrieved secrets from the vault on every request. Caching secrets locally eliminates redundant calls, reduces latency from tens of milliseconds per vault call to microseconds for a local cache lookup, and keeps the application well within throttling boundaries. This unit covers caching patterns, cache invalidation strategies, and how to balance performance with security by controlling cache lifetime.

### Understand Key Vault throttling limits

Azure Key Vault enforces throttling limits to protect the service from excessive load. When your application exceeds these limits, Key Vault returns HTTP 429 (Too Many Requests) responses. Understanding these limits helps you design a caching strategy that prevents throttling while maintaining access to fresh credentials.

For secret operations, Key Vault allows up to 4,000 GET transactions per vault per ten-second window in a given region. Write operations (CREATE, IMPORT) share a collective limit of 300 transactions per ten-second window. Each Azure subscription has an additional aggregate limit of five times the per-vault limit across all vaults in a region.

> Note
> Key Vault throttling limits and quotas change regularly. For the latest details, see Azure Key Vault service limits.

These limits are generous for applications that cache secrets, but an AI service that calls `get_secret()` on every incoming request without caching can easily reach 4,000 reads in 10 seconds during traffic spikes. Caching transforms the access pattern from thousands of vault calls to a few periodic refreshes.

### Implement a time-based in-memory cache

The simplest caching pattern stores the secret value in memory with a timestamp and refreshes the value after a configurable interval. This approach works for secrets that change infrequently, such as API keys that rotate every 90 days. A short staleness window (such as 15 minutes or one hour) is acceptable for most AI workloads because credential rotation is a planned event with a transition period, not an instantaneous switch.

```python
# Code fragment - focus on time-based caching pattern
import time
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

class SecretCache:
    def __init__(self, vault_url, cache_ttl_seconds=900):
        credential = DefaultAzureCredential()
        self._client = SecretClient(vault_url=vault_url, credential=credential)
        self._cache = {}
        self._cache_ttl = cache_ttl_seconds

    def get_secret(self, secret_name):
        cached = self._cache.get(secret_name)
        now = time.monotonic()

        if cached and (now - cached["timestamp"]) < self._cache_ttl:
            return cached["value"]

        secret = self._client.get_secret(secret_name)
        self._cache[secret_name] = {
            "value": secret.value,
            "timestamp": now
        }
        return secret.value
```

The `cache_ttl_seconds` parameter controls how often the cache refreshes from Key Vault. A value of 900 seconds (15 minutes) means each secret is fetched at most four times per hour per application instance. For an AI service with 10 replicas, this translates to 40 vault calls per hour per secret instead of potentially millions of calls without caching. The `time.monotonic()` function provides a clock that isn't affected by system time adjustments, making it reliable for measuring elapsed intervals.

### Invalidate the cache with Azure Event Grid

Time-based caching introduces a staleness window where the application might use an old credential after rotation. For tighter cache freshness, you can subscribe to Key Vault's `SecretNewVersionCreated` event through Azure Event Grid. When someone stores a new secret version, Event Grid delivers a notification to your application through a webhook, Azure Function, or Service Bus queue. The application invalidates its local cache and retrieves the new secret on the next access. The event-driven invalidation process follows these steps:

A new secret version is stored in Key Vault.
Event Grid delivers a `SecretNewVersionCreated` event to the application through a webhook, Service Bus queue, or Azure Function.
The application invalidates the cached secret.
The next access retrieves the fresh value from Key Vault.

This event-driven approach combines the low latency of caching with near-real-time freshness. The cache only refreshes when a secret actually changes, rather than on a fixed timer. You can implement both patterns together as a defense-in-depth strategy: use Event Grid for immediate notifications and time-based expiration as a fallback in case an event delivery fails.

### Choose the right cache scope

The scope of your cache determines how many Key Vault calls your application fleet makes collectively. Different cache scopes involve different trade-offs between simplicity, consistency, and total API call volume.

**Per-process** cache is the simplest approach. Each application instance maintains its own in-memory cache. This works well for stateless services where each instance independently retrieves and caches secrets. The total number of Key Vault calls scales linearly with the number of instances. For an AI service with 10 replicas and a fifteen-minute cache TTL, you get at most 40 vault calls per hour per secret across the fleet. This is the recommended starting point for most applications.

**Shared distributed cache** uses an external store such as Azure Managed Redis as an intermediate layer between the application and Key Vault. One process fetches the secret from Key Vault and writes it to the shared cache. All other instances read from the shared cache instead of calling Key Vault directly. This approach reduces total Key Vault calls to one per refresh cycle regardless of instance count. However, it adds operational complexity and introduces a dependency on the shared cache infrastructure. It also means secrets are stored in an additional location outside Key Vault, which requires its own access control and encryption considerations.

**Application startup preloading** retrieves all required secrets at application startup and stores them in memory for the lifetime of the process. This pattern works for containerized services with rolling updates where instances restart periodically, and for secrets that rarely change. You can combine startup preloading with a periodic background refresh to handle secrets that rotate during the application's uptime. This approach is straightforward to implement and ensures that all secrets are available before the application begins processing requests.

```python
# Code fragment - focus on startup preloading pattern
class AppConfig:
    def __init__(self, vault_url, secret_names):
        credential = DefaultAzureCredential()
        client = SecretClient(vault_url=vault_url, credential=credential)

        self._secrets = {}
        for name in secret_names:
            secret = client.get_secret(name)
            self._secrets[name] = secret.value

    def get(self, secret_name):
        return self._secrets.get(secret_name)

# At application startup
config = AppConfig(
    vault_url="https://kv-ragpipeline-prod.vault.azure.net/",
    secret_names=["openai-api-key", "cosmosdb-connection-string",
                  "blob-storage-key"]
)

# During request processing - no vault calls
api_key = config.get("openai-api-key")
```

### Balance cache lifetime with security requirements

The cache lifetime you choose depends on your rotation frequency and the acceptable staleness window. Shorter cache lifetimes provide fresher credentials but increase Key Vault API calls. Longer lifetimes reduce API calls but extend the window where a rotated-out credential might still be in use.

For API keys that rotate every 90 days, a one-hour cache TTL is appropriate. The staleness window is at most one hour, which is small relative to the ninety-day rotation cycle. For credentials that might be revoked on short notice (such as after a security incident), a shorter cache lifetime of five minutes or event-driven invalidation through Event Grid is necessary. In emergency rotation scenarios, you might also restart application instances to force an immediate cache refresh.

Consider these guidelines when choosing a cache TTL:

**High-rotation secrets (daily or weekly)**: Use a five-to-fifteen-minute TTL combined with Event Grid notifications.
**Standard-rotation secrets (monthly or quarterly)**: Use a thirty-to-sixty-minute TTL. Event Grid is beneficial but not critical.
**Low-rotation secrets (annual or static)**: Use startup preloading with periodic refresh every few hours.

### Handle throttling gracefully

When your application receives a 429 response from Key Vault, implement exponential backoff with jitter before retrying. The Azure SDK's built-in retry policy handles most transient errors, but your application should also log throttling events to identify opportunities for better caching. A pattern of frequent 429 responses indicates that the cache lifetime is too short or that some code paths bypass the cache.

The recommended retry sequence follows exponential backoff: wait one second, then two seconds, then four seconds, then eight seconds, and then 16 seconds. Adding random jitter to each wait interval prevents multiple application instances from retrying simultaneously and creating a thundering herd effect.

```python
# Code fragment - focus on logging throttling events for cache tuning
import logging

logger = logging.getLogger("keyvault")

def get_secret_with_monitoring(cache, secret_name):
    try:
        return cache.get_secret(secret_name)
    except HttpResponseError as e:
        if e.status_code == 429:
            logger.warning(
                "Key Vault throttled request for '%s'. "
                "Consider increasing cache TTL.", secret_name
            )
        raise
```

Monitoring throttle events across your application fleet helps you tune the cache TTL over time. If you never see 429 responses, your caching strategy is working correctly. If you see occasional 429 responses during deployment windows (when multiple instances start simultaneously and preload secrets), consider staggering instance startup or using a shared cache to reduce the burst of initial vault calls.

### Additional resources

[Azure Key Vault throttling guidance](https://learn.microsoft.com/en-us/azure/key-vault/general/overview-throttling)
[Monitoring Key Vault with Azure Event Grid](https://learn.microsoft.com/en-us/azure/key-vault/general/event-grid-overview)
[Best practices for using Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)

## Summary

In this module, you learned how Azure Key Vault provides centralized, secure storage for the secrets, keys, and certificates that AI applications depend on. You explored the three object types that Key Vault stores and how to organize vaults with per-application boundaries, descriptive naming conventions, and tags for metadata. You also learned how Azure RBAC controls access through fine-grained roles such as Key Vault Secrets User and Key Vault Secrets Officer, and how managed identities eliminate the need to store vault credentials in application code. You retrieved secrets programmatically using the Python `azure-keyvault-secrets` SDK with `DefaultAzureCredential`, which chains multiple authentication methods to work seamlessly across development and production environments. You examined Key Vault's versioning model, where each `set_secret()` call creates a new version, and explored rotation strategies including manual rotation, automated rotation with Event Grid, and dual-credential rotation for services that support two active keys. You implemented a retry-on-auth-failure pattern that enables zero-downtime credential transitions. Finally, you built caching strategies that reduce Key Vault API calls from thousands per hour to a handful of periodic refreshes, using time-based in-memory caching and event-driven invalidation through Event Grid to balance performance with credential freshness.

### Additional resources

[Azure Key Vault documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
[Azure Key Vault secrets client library for Python](https://learn.microsoft.com/en-us/python/api/overview/azure/keyvault-secrets-readme)
[Best practices for using Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
[Automate secret rotation](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation-dual)