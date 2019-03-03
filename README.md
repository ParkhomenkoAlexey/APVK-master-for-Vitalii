# APVK master for Vitalii

## Запуск приложения 

Для успешного запуска данного приложения никаких сторонних подов скачивать не нужно, так как они уже внедрены в проект через менеджер зависимостей `carthage`. Для отображения новостной ленты необходимо авторизироваться через веб-интерфейс от "ВКонтакте" который появится сразу после запуска приложения. 


## Перемещение между FeedViewController/NewFeedViewController/PerfectFeedViewController

#### AppDelegate.swift file
```swift
func authServiceDidSignIn() {
        if !(window?.rootViewController is PerfectFeedViewController) {
            
            let feedVC = PerfectFeedViewController.loadFromStoryboard()
            let navVC = UINavigationController(rootViewController: feedVC)
            window?.rootViewController = navVC
        }
    }
```
В данном коде по умолчанию будет загружаться `PerfectFeedViewController`. Для подгрузки другого `ViewController` в тех местах где указан `PerfectFeedViewController` следует заменить `PerfectFeedViewController` на желаемый.

`FeedViewController`/`NewFeedViewController`/`PerfectFeedViewController` абсолютно идентичны по функционалу, поэтому при подгрузке любого `ViewController` будет происходить одно и тоже. Разница заключается лишь в реализации архитектуры "Clean swift" внутри данных ViewControllers

## Краткое описание

### FeedViewController
Данный `ViewController` мы рассматривали неделю назад, в нем абсолютно ничего не изменилось.

### NewFeedViewController

 Реализовал архитектуру "Clean swift" внутри данного `ViewController` используя готовый шаблон от Виталия. 
 Однако отклонился в реализации модели для данного VC от шаблона: вместо `switch case` создал отдельный метод для каждого действия. 
 Из хороших новостей все остальные каноны архитектуры "clean swift" учел.
 
 ### PerfectFeedViewController
 
 На то он и Perfect, что реализовал в нем модель для данного VC следуя шаблону. В остальном ничем не отличается от `NewFeedViewController`
 
 ### P.S
 `NewFeedViewController` реализовал потому что сначала не получилось разобраться с моделью через `switch case`, затем уже смог.
 
