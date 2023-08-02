# MyDocker
Здесь записи с моего обучения Docker и Docker Compose 


## Первый опыт.
Есть проект - таск менеджер todo. Сначала я создал Dockerfile, который создает контейнер основе образа node:18-alpine, делает рабочей директорий /app, переносит все файлы из текущей директории, запускает файл src/index.js и открывает 3000 порт. Вот [Dockerfile](https://github.com/VladimirSemchishin/MyDocker/blob/main/Dockerfile "Ссылка на Dockerfile")
