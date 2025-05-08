@echo off

rem Clique duas vezes neste arquivo para dar um commit comum
rem Se você simplesmente digitar "Commitar" no terminal dessa pasta, vai dar um commit comum também

rem Mas se você escrever "Commitar <mensagem>", sua mensagem irá aparecer como a mensagem do commit
rem NÃO adicione aspas duplas ao redor de sua mensagem, deixe ela pura no terminal

rem Exemplo:
rem commitar Melhorias no código que utiliza a árvore B+

IF "%~1"=="" (
    git add .
    git commit -m "Commit comum"
    git push origin main
	
) ELSE (
    git add .
    git commit -m "%*"
    git push origin main
    
)