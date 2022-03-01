@ECHO OFF
SETLOCAL EnableDelayedExpansion

TITLE Zombie Tracker

@REM Global Variables
SET "name="
SET "age="
SET "type="
SET "location="
SET "speciality="
SET "eatsBrains="

@REM Constants
SET "zombieTypes[0]="
SET "counter=0"
FOR %%x in ( Walking Runner Blue_Walker Voodoo Ghoul Crawler ) DO (
	SET "zombieTypes[!counter!]=%%x"
	SET /A counter+=1
)
SET /A zombieTypes.len=%counter%-1

SET "zombieSpecialties[0]="
SET "counter=0"
FOR %%x in ( Spitter Explorer Tank Hazmats ) DO (
	SET "zombieSpecialties[!counter!]=%%x"
	SET /A counter+=1
)
SET /A zombieSpecialties.len=%counter%-1

@REM Start
GOTO :Main

@REM Graphics

:LoadNewSighting <return>
	CLS
	SET "return=%~1"

	:_NSName
	ECHO Name your zombie!
	SET /P "name=> %=%"
	ECHO.

	:_NSAge
	ECHO how old is %name%?
	SET /P "age=> %=%"
	
	ECHO %age%| FINDSTR /r "^[0-9][0-9]*$" > NUL
	IF %ERRORLEVEL% NEQ 0 ( GOTO :_NSAge )
	ECHO.

	
	@REM ECHO How many typings does %name% have?
	@REM SET /P "length=> %=%"
	@REM SET /A types.len=%length%-1
	@REM ECHO.

	ECHO ======Typings======
	FOR /L %%x in ( 0,1,%zombieTypes.len% ) DO (
		ECHO ^( %%x ^) !zombieTypes[%%x]!
	)
	ECHO ===================
	ECHO.

	:_NSTyping
	ECHO please enter %name%'s type?

	SET /P "input=> %=%"

	ECHO %input%| FINDSTR /r "^[0-9][0-9]*$" > NUL
	IF %ERRORLEVEL% NEQ 0 ( GOTO :_NSTyping )
	IF %input% LSS 0 ( GOTO :_NSTyping )
	IF %input% GTR %zombieTypes.len% ( GOTO :_NSTyping )

	SET "type=!zombieTypes[%input%]!"
	
	:_NSLocation
	ECHO Where did you last see %name%
	SET /P "location=> %=%"
	ECHO.

	ECHO ====Specialities====
	FOR /L %%x in ( 0,1,%zombieSpecialties.len% ) DO (
		ECHO ^( %%x ^) !zombieSpecialties[%%x]!
	)
	ECHO ====================
	ECHO.

	:_NSSpecial
	ECHO What is %name%'s Speciality? 
	
	SET /P "input=> %=%"
	
	ECHO %input%| FINDSTR /r "^[0-9][0-9]*$" > NUL
	IF %ERRORLEVEL% NEQ 0 ( GOTO :_NSSpecial )
	IF %input% LSS 0 ( GOTO :_NSSpecial )
	IF %input% GTR %zombieSpecialties.len% ( GOTO :_NSSpecial )

	SET "speciality=!zombieSpecialties[%input%]!"
	ECHO.

	:_NSBrains
	ECHO Does %name% eat brains? [y/n]
	SET /P "input=> %=%"
	IF "%input%" EQU "y" ( SET "eatsBrains=true" ) ELSE (
	IF "%input%" EQU "n" ( SET "eatsBrains=false" ) ELSE (
		GOTO :_NSBrains
	))


	SET "%return%.name=%name%"
	SET "%return%.age=%age%"
	SET "%return%.type=%type%"
	SET "%return%.location=%location%"
	SET "%return%.speciality=%speciality%"
	SET "%return%.eatsBrains=%eatsBrains%"

EXIT /B 0

:LoadGui
	ECHO ^.================================================^.
	ECHO ^| Zombie Record Keeping                          ^|
	ECHO ^|================================================^|
	ECHO ^|                                                ^|
	ECHO ^|   ^( 1 ^)  New Zombie Sighting                   ^|
	ECHO ^|   ^( 2 ^)  View All Sightings                    ^|
	ECHO ^|   ^( 3 ^)  Zombie File Lookup                    ^|
	ECHO ^|   ^( 4 ^)  Update Zombie File                    ^|
	ECHO ^|   ^( 5 ^)  Remove Zombie File                    ^|
	ECHO ^|   ^( 6 ^)  Exit                                  ^|
	ECHO ^|                                                ^|
	ECHO ^'================================================^'
EXIT /B 0 


@REM Functions

:NewSighting
	CLS
	SET "zombie="
	CALL :LoadNewSighting zombie
	python Query.py "query" "INSERT INTO zombieLog VALUES('%zombie.name%', '%zombie.age%', '%zombie.type%', '%zombie.location%', '%zombie.speciality%', '%zombie.eatsBrains%')" 

EXIT /B 0 

:ViewAll
	CLS
	ECHO ======Current Zombie Index======
	ECHO.
	python Query.py "fetch" ""

	ECHO ================================
	ECHO.

	ECHO Press Any key to Return to Menu
	PAUSE > NUL
EXIT /B 0

:ViewSingle
	CLS 
	ECHO How would you like to search?
	ECHO ( ^1 ) Name
	ECHO ( ^2 ) Age
	ECHO ( ^3 ) ^Type
	ECHO ( ^4 ) Location
	ECHO ( ^5 ) Speciality
	ECHO ( ^6 ) Eats brains

	SET /P "input= > %=%"
	ECHO.

	ECHO %input%| FINDSTR /r "^[0-9][0-9]*$" > NUL
	IF %ERRORLEVEL% NEQ 0 ( GOTO :ViewSingle )
	IF %input% LSS 1 ( GOTO :ViewSingle )
	IF %input% GTR 6 ( GOTO :ViewSingle )


	IF %input% EQU 1 ( CALL :_VSName )
	IF %input% EQU 2 ( CALL :_VSAge )
	IF %input% EQU 3 ( CALL :_VSType )
	IF %input% EQU 4 ( CALL :_VSLocation )
	IF %input% EQU 5 ( CALL :_VSSpeciality )
	IF %input% EQU 6 ( CALL :_VSEatsBrains )

	ECHO Press Any key to Return to Menu
	PAUSE > NUL

	EXIT /B 0

	:_VSName
		ECHO what is the name of the zombie you are looking for?
		SET /P "name= > %=%"

		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE name='%name%'"

		ECHO ================================
		ECHO.
		
		ECHO Press Any key to Return to Menu
		PAUSE > NUL

	EXIT /B 0
	:_VSAge
		ECHO how old is the zombie you are looking for?
		SET /P "age= > %=%"
		
		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE age='%age%'"

		ECHO ================================
		ECHO.
		
	EXIT /B 0
	:_VSType
		ECHO What type of zombie are you looking for?
		ECHO ( 0 ) Walking
		ECHO ( 1 ) Runner
		ECHO ( 2 ) Blue_Walker
		ECHO ( 3 ) Voodoo
		ECHO ( 4 ) Ghoul
		ECHO ( 5 ) Crawler

		SET /P "input= > %=%"

		SET "type="
		if %input% EQU 0 ( SET "type=Walking" )
		if %input% EQU 1 ( SET "type=Runner" )
		if %input% EQU 2 ( SET "type=Blue_Walker" )
		if %input% EQU 3 ( SET "type=Voodoo" )
		if %input% EQU 4 ( SET "type=Ghoul" )
		if %input% EQU 5 ( SET "type=Crawler" )
		
		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE type='%type%'"

		ECHO ================================
		ECHO.
		
	EXIT /B 0
	:_VSLocation
		ECHO where was your zombie last seen?
		SET /P "location= > %=%"
		
		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE location='%location%'"

		ECHO ================================
		ECHO.
	EXIT /B 0
	:_VSSpeciality
		ECHO What speciality of zombie are you looking for?
		ECHO ( 0 ) Spitter
		ECHO ( 1 ) Explorer
		ECHO ( 2 ) Tank
		ECHO ( 3 ) Hazmats

		SET /P "input= > %=%"

		SET "special="
		if %input% EQU 0 ( SET "special=Spitter" )
		if %input% EQU 1 ( SET "special=Explorer" )
		if %input% EQU 2 ( SET "special=Tank" )
		if %input% EQU 3 ( SET "special=Hazmats" )
		
		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE speciality='%special%'"

		ECHO ================================
		ECHO.
		

	EXIT /B 0
	:_VSEatsBrains
		ECHO What kind of zombies do you want to look for?
		ECHO ( ^1 ) Brain Eaters
		ECHO ( ^2 ) Non-Brain Eaters
		

		SET /P "input= > %=%"

		SET "eatsBrains="
		if %input% EQU 1 ( SET "eatsBrains=true" )
		if %input% EQU 2 ( SET "eatsBrains=false" )
		
		ECHO.
		ECHO ======Current Zombie Index======
		ECHO.
		python Query.py "fetch" "WHERE eatsBrains='%eatsBrains%'"

		ECHO ================================
		ECHO.
		
	EXIT /B 0


EXIT /B 0

:Update
	CLS
	ECHO what is the name of the zombie youd like to update?
	SET /P "name=> %=%"
	ECHO. 

	ECHO What About %name% would you like to change?
	ECHO ( ^1 ) Name
	ECHO ( ^2 ) Age
	ECHO ( ^3 ) ^Type
	ECHO ( ^4 ) Location
	ECHO ( ^5 ) Speciality
	ECHO ( ^6 ) Eats brains
	SET /P "input=> %=%"
	ECHO.

	SET "type="
	IF %input% EQU 1 ( SET "type=name" )
	IF %input% EQU 2 ( SET "type=age" )
	IF %input% EQU 3 ( SET "type=type" )
	IF %input% EQU 4 ( SET "type=location" )
	IF %input% EQU 5 ( SET "type=speciality" )
	IF %input% EQU 6 ( SET "type=eatsBrains" )

	ECHO what value would you like to change said value to?
	SET /P "value=> %=%"
	ECHO.

	python Query.py "query" "UPDATE zombieLog SET %type%='%value%' WHERE name='%name%'" 

	ECHO Type, %type% has been changed to %value% on %name%. 
	ECHO Press Any key to Return to Menu
	PAUSE > NUL
EXIT /B 0

:Remove
	CLS
	ECHO what was the name of your zombie youd like to delete?

	SET /P "name= > %=%"

	python Query.py "query" "DELETE FROM zombieLog WHERE name='%name%'" 

	ECHO.
	ECHO %name% has been deleted
	
	ECHO Press Any key to Return to Menu
	PAUSE > NUL
EXIT /B 0


:MainMenu
	CLS
	CALL :LoadGui

	:_UserInput
	SET /P "userInput=> %=%"

	IF "%userInput%" EQU "1" ( CALL :NewSighting )
	IF "%userInput%" EQU "2" ( CALL :ViewAll )
	IF "%userInput%" EQU "3" ( CALL :ViewSingle )
	IF "%userInput%" EQU "4" ( CALL :Update )
	IF "%userInput%" EQU "5" ( CALL :Remove )
	IF "%userInput%" EQU "6" ( CALL :ExitAsk MainMenu )
GOTO :MainMenu

:ExitAsk <ret>
	SET "ret=%~1"

	CLS
	ECHO Are you sure you'd like to leave? [y/N]
	SET /P "userInput=> %=%"
	IF "%userInput%" EQU "y" ( GOTO :Exit )
	IF "%userInput%" EQU "N" ( GOTO :%ret% )

GOTO :ExitAsk	

@REM Start
:Main
	python Query.py "query" "CREATE TABLE IF NOT EXISTS zombieLog(name TEXT, age FLOAT, type TEXT, location TEXT, speciality TEXT, eatsBrains TEXT)" 
	GOTO :MainMenu

@REM Leave The Program
:Exit 
	@REM PAUSE
	EXIT



