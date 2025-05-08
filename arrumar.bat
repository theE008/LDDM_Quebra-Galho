@echo off

rem Arruma dependências, sempre rode ao abrir o projeto

git pull
flutter pub get
flutter upgrade
