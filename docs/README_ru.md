# ScreenPilot

> 🇬🇧 [English version](../README.md)

Легковесная библиотека навигации для UIKit, предоставляющая единый async API для push, modal и сложной смешанной навигации.

<!-- shields -->

---

## 📋 Содержание

- [Требования](#требования)
- [Установка](#установка)
- [Быстрый старт](#быстрый-старт)
- [Стили навигации](#стили-навигации)
- [Закрытие экранов](#закрытие-экранов)
- [Анимации](#анимации)
- [Требования для навигации](#требования-для-навигации)
- [Дедупликация экранов](#дедупликация-экранов)
- [Лицензия](#лицензия)

---

## Требования

- iOS 16.0+
- Swift 6.0+
- Xcode 15.0+

## Установка

### Swift Package Manager

В Xcode: **File → Add Package Dependencies**, вставьте URL репозитория:

```
https://github.com/Hank2354/ScreenPilot
```

Или добавьте в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Hank2354/ScreenPilot", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["ScreenPilot"]
    )
]
```

## Быстрый старт

### 1. Создайте навигатор

Передайте корневой view controller приложения (обычно из `UIWindow`):

```swift
import ScreenPilot

let rootProvider = SPRootViewControllerProvider(rootViewController: window.rootViewController!)
let navigator = SPNavigator(rootViewControllerProvider: rootProvider)
```

### 2. Опишите экран

Оберните view controller в `SPScreenPrototype`:

```swift
let profileScreen = SPScreenPrototype(
    factory: { ProfileViewController() },
    requirements: []
)
```

### 3. Перейдите на экран 🚀

```swift
// Push
await navigator.navigate(to: [profileScreen], style: .push)

// Модальный показ
await navigator.navigate(to: [profileScreen], style: .modal(.fullScreen))

// Обработка результата
let result = await navigator.navigate(to: [profileScreen], style: .push)
if case .failure(let error) = result {
    print("Навигация не удалась: \(error)")
}
```

## Стили навигации

| Стиль | Описание |
|-------|----------|
| `.push` | Добавляет в navigation stack |
| `.modal(UIModalPresentationStyle)` | Модальный показ с заданным стилем |
| `.replaceTop` | Заменяет верхний view controller в стеке |
| `.setStack` | Полностью заменяет navigation stack |

## Закрытие экранов

ScreenPilot предоставляет точный контроль над закрытием экранов:

```swift
// Закрыть один экран из стека
await navigator.pop()

// Закрыть несколько экранов
await navigator.pop(count: 3)

// Закрыть до конкретного view controller
await navigator.popTo(homeViewController)

// Закрыть до корня navigation stack
await navigator.popToRoot()

// Закрыть верхний modal
await navigator.dismiss()

// Закрыть все modal
await navigator.dismissAll()
```

### `close` — умное закрытие в смешанной иерархии 🧠

`close` умно обрабатывает иерархии, в которых push и modal навигация смешаны:

```swift
// Иерархия: Root → A → B → Modal(Nav → C → D → E)

await navigator.close(count: 1)  // Закрывает E
await navigator.close(count: 4)  // Закрывает E, D, C и modal — возвращает на B
await navigator.close(count: 5)  // Закрывает E, D, C, modal, B — возвращает на A

await navigator.closeTo(viewControllerA)  // Закрывает всё до A
await navigator.closeAll()               // Закрывает всё до корня
```

## Анимации

Все методы навигации принимают опциональный параметр `SPNavigationAnimation`:

```swift
// Системная анимация по умолчанию
await navigator.pop(animation: .default)

// Без анимации
await navigator.pop(animation: .none)

// Кастомная анимация через UIViewControllerAnimatedTransitioning
let customAnim = SPNavigationAnimation(
    appear: .custom(myAppearTransition),
    disappear: .custom(myDisappearTransition)
)
await navigator.navigate(to: [screen], style: .push, configuration: .init(animation: customAnim))
```

## Требования для навигации

Защитите экраны кастомной логикой проверки через `SPScreenRequirement` 🔒:

```swift
struct AuthRequirement: SPScreenRequirement {
    let authService: AuthService

    var isSatisfied: Bool {
        authService.isAuthenticated
    }
}

let profileScreen = SPScreenPrototype(
    factory: { ProfileViewController() },
    requirements: [AuthRequirement(authService: authService)]
)

// Если требование не выполнено, навигация вернёт .failure(.requirementNotSatisfied)
let result = await navigator.navigate(to: [profileScreen], style: .push)
```

## Дедупликация экранов

Используйте `SPNavigationConfiguration` с `SPScreenFinder`, чтобы переходить к уже
существующему экрану в иерархии, а не создавать новый:

```swift
let config = SPNavigationConfiguration(screenFinder: SPDefaultScreenFinder())

// Если ProfileViewController уже есть в иерархии — навигатор вернётся к нему,
// а не откроет новый экземпляр
await navigator.navigate(to: [profileScreen], style: .push, configuration: config)
```

### Сопоставление по контексту 🎯

Чтобы различать несколько экземпляров одного типа экрана, реализуйте `SPScreenContextComparable`:

```swift
class ProductViewController: UIViewController, SPScreenContextComparable {
    let productId: String

    var contextHash: AnyHashable { productId }
}
```

`SPDefaultScreenFinder` будет сопоставлять и тип, и `contextHash` — переход к
`ProductViewController(productId: "abc")` не попадёт на `ProductViewController(productId: "xyz")`.

## Лицензия

ScreenPilot доступен по лицензии MIT.
