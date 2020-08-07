
# Azure Data Factory Architecture Patterns
## Architecture and Composable Deployment Code

### Virtual Network Foundation
#### Implementation
![adfarch](https://user-images.githubusercontent.com/22504173/88923589-f4335980-d23f-11ea-9aa0-f69fee0d2aff.png)

### Provisioning Azure Data Factory with or without CI\CD integration (Automation templates)
### Provisioning Azure Integration Runtime – Custom clusters, Managed VNET concepts
### Provisioning Self Hosted Integration Runtime, Considerations


## Composable Deployment Code
Below you'll find a set of fully parameterized ARM templates that can be used to deploy the above noted architecture. 

These ARM templates have been constructed in a modular way to optimize reuse potential.

Within each of the below folders you'll find a deploy.sh file that provides an example of how to sequentially deploy the templates with the appropriate parameters.

1. [Base Network](components/base-network)
2. [Data Factory](components/data-factory)
3. [Self Hosted Integration runtime](components/self-hosted-integration-runtime)

