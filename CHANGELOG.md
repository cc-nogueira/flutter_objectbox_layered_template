## [0.0.2] - 2022-06-01
> Updated to the latest version of Layered Template:
> Flutter updated to 3.0 and Dart to 2.17.  
> Configuring internationalization.  
>  
> - Using DART 2.17 new super arguments.
> - Using lint 2.0.1.
> - Using Flutter l10n for internationalization with ARB files.

## [0.0.1] - 2022-04-05

### Template for Flutter Layered Architecture using ObjectBox persistence.
> This is an extension from Flutter Layered Template now using StreamAPI and
> ObjectBox for local persistence.  

> Defined **Layered Architecture Structure** with **each layer in an internal package**:  
>   - **Core** (Basic interfaces and utilities)  
>   - **Domain Layer** (Business Entities and Business Rules)  
>   - **Data Layer** (Persistence)  
>   - **Service Layer** (External services)  
>   - **Presentation Layer** (UI)  
>   - **DI Layer** (Dependency Injection)  

> **Layered Implementation** using **Riverpod Providers**, **ObjectBox** and **Freezed** libraries:  
>   - Per layer exports to define public/private members for each layer  
>   - Each layer has a AppLayer Object to coordinate inter-layer interactions  
>   - Using ObjectBox local persistence  
>   - Using Riverpod for layer instantiation and initialization  
>   - Using Riverpod for layer configuration with Dependency Inversion  
>   - Using Riverpod to expose layer implementations  
>   - Using Freezed classes for Entities  
>   - The example App presentation uses Riverpod for StateManagement with its Stream API.  

> **main() implementation to provide global injection scope and initialize all layers**:
>   - Wrap the whole application in Riverpod ProviderScope  
>   - Use a FutureProvider to:  
>     - Async initialize the DI Layer (which initialize and configure all other layers)  
>     - Create main App widget after initialization  

> **Example Usecase Implementation**
>   - Domain entities, Domain exceptions, Domain repository interfaces, Domain usecases  
>   - Data repository implementation  
>   - Dependency Inversion (also Dependency Injection) via AppLayer instances and providers  

> **Common Code** extracted to correct locations  
>   - Common code in Core folder  
>   - Common pages in /lib/presentation/common/page  
>   - Named routes configuration and implementation  

> **Testing Domain Usecase**  
>   - Testing Domain Usecase business rules with Mockito  
