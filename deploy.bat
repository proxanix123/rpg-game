@echo off
chcp 65001 >nul
title RPG Game Deploy Script
color 0A

echo ============================================
echo   RPG GAME AUTO DEPLOY SCRIPT
echo   proxanix123/rpg-game
echo ============================================
echo.

:: Проверка: уже ли установлен Git
where git >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Git уже установлен
    goto :check_files
) else (
    echo [INFO] Git не найден, устанавливаю...
)

:: Скачиваем Git Portable через PowerShell
set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.2/Git-2.47.1.2-64-bit.exe
set GIT_INSTALLER=%TEMP%\GitInstaller.exe

echo [DOWNLOAD] Скачиваю Git installer...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GIT_URL%' -OutFile '%GIT_INSTALLER%' -UseBasicParsing }"

if not exist "%GIT_INSTALLER%" (
    echo [ERROR] Не удалось скачать Git!
    echo Проверь интернет и попробуй снова.
    pause
    exit /b 1
)

echo [INSTALL] Устанавливаю Git (тихий режим)...
"%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh" /o:PathOption=CmdTools /o:CRLFOption=CRLFCommitAsIs /o:BashTerminalOption=ConHost /o:EnableSymlinks=Enabled /LOG="%TEMP%\git_install.log"

if %errorlevel% neq 0 (
    echo [ERROR] Ошибка установки Git! Код: %errorlevel%
    echo Лог: %TEMP%\git_install.log
    pause
    exit /b 1
)

del "%GIT_INSTALLER%" >nul 2>&1

:: Обновляем PATH для текущей сессии
set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"

:: Проверяем что Git работает
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Git установлен, но не в PATH. Добавляю вручную...
    set "PATH=C:\Program Files\Git\cmd;%PATH%"
    where git >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Git всё ещё не найден после установки!
        echo Перезапусти скрипт или установи Git вручную: https://git-scm.com
        pause
        exit /b 1
    )
)

echo [OK] Git установлен успешно!
git --version

:check_files
echo.
echo [CHECK] Проверяю файлы проекта...

if not exist "index.html" (
    echo [ERROR] index.html не найден в текущей папке!
    echo Убедись что запускаешь скрипт из папки проекта.
    echo Текущая папка: %CD%
    pause
    exit /b 1
)

if not exist "css\style.css" (
    echo [ERROR] css\style.css не найден!
    pause
    exit /b 1
)

if not exist "js\app.js" (
    echo [ERROR] js\app.js не найден!
    pause
    exit /b 1
)

echo [OK] Все файлы на месте

:: Настройка Git
echo.
echo [CONFIG] Настраиваю Git...
git config --global user.name "proxanix123"
git config --global user.email "proxanix123@users.noreply.github.com"
git config --global init.defaultBranch main
echo [OK] Git настроен

:: Инициализация репозитория
echo.
echo [INIT] Инициализирую репозиторий...

:: Удаляем старый .git если есть (чистый старт)
if exist ".git" (
    echo [WARN] Найден существующий .git, удаляю для чистого деплоя...
    rmdir /s /q ".git"
)

git init
if %errorlevel% neq 0 (
    echo [ERROR] git init не удался!
    pause
    exit /b 1
)

git add .
git commit -m "loading screen - initial deploy"
git branch -M main
git remote add origin https://github.com/proxanix123/rpg-game.git 2>nul

:: Если remote уже существует — обновляем URL
git remote set-url origin https://github.com/proxanix123/rpg-game.git

echo.
echo ============================================
echo   ВАЖНО! СЕЙЧАС ПОТРЕБУЕТСЯ АВТОРИЗАЦИЯ
echo ============================================
echo.
echo При первом push GitHub попросит логин/пароль.
echo ПАРОЛЬ ОТ GITHUB НЕ РАБОТАЕТ!
echo.
echo Нужно создать Personal Access Token:
echo 1. Открой в браузере:
echo    https://github.com/settings/tokens/new
echo 2. Note: rpg-deploy
echo 3. Expiration: No expiration
echo 4. Поставь галочку на "repo"
echo 5. Generate token → скопируй
echo 6. Вставь ТОКЕН вместо пароля
echo.
echo Или проще: установи GitHub Desktop потом
echo https://desktop.github.com
echo.
echo ============================================
echo.

set /p READY="Готов к push? Создай токен и нажми ENTER..."

echo.
echo [PUSH] Пушу на GitHub...
git push -u origin main --force

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push не удался!
    echo Возможные причины:
    echo   - Неправильный токен
    echo   - Репозиторий не создан на GitHub
    echo   - Нет интернета
    echo.
    echo Создай репозиторий: https://github.com/new
    echo Имя: rpg-game, Public, без README
    echo Потом перезапусти этот скрипт.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   [SUCCESS] ДЕПЛОЙ ЗАВЕРШЁН!
echo ============================================
echo.
echo Репозиторий: https://github.com/proxanix123/rpg-game
echo.
echo ТЕПЕРЬ ВКЛЮЧИ GITHUB PAGES:
echo 1. Открой: https://github.com/proxanix123/rpg-game/settings/pages
echo 2. Source: Deploy from a branch
echo 3. Branch: main, Folder: / (root)
echo 4. Save
echo 5. Подожди 1-2 минуты
echo.
echo Твой сайт: https://proxanix123.github.io/rpg-game/
echo.
echo Потом подключи как Telegram Mini App через @BotFather
echo.
echo ============================================
pause