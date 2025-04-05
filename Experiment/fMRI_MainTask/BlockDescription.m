function [L_1] = BlockDescription(Language)
switch Language
    case 'English'
        active_mode = 0
    case 'Deutsch'
        active_mode = 1
    otherwise
        error ('Input language is wrong. Please state English or Deutsch')
end

if active_mode == 0
    L_1 ={ 'We will shortly begin the Experiment'
    'During the whole experiment, you will be asked to either move your finger through a white target'
    'OR'
    'move your finger to an arbitrary direction'
    'TARGET MOVEMENT'
    'Every trial starts with a white dot in the middle of the screen.'
    'As soon as your finger is within the starting position it will turn out to green,'
    'and at the same time you see a target on the right side with the same color (white).'
    'You need to draw a fast and straight line from middle dot to the target.'
    'When your movement is finished, lift up your hand and be prepared for the next trial.'
    'NO TARGET MOVEMENT'
    'It always starts with a count down, after that you are free to choose any direction in the allowed direction.'
    'You will not get any feedback on your finger''s location.'
    'When the movement phase is finished, you will go through another fixation phase.'
    'Try to fixate on the fixation mark.' 
    'For the response phase, you have the control of button box in your left hand.'
    'You have a limited time to go back and forth between the markers and confirm your selected marker with button ..'
    'Please bear in mind to distribute your spatial movement directions'
    'If you are ready, We will start the session...' };
    
    %     % Task Description lines in Post-Adaptation
%     L_2 = { ' In Each trial, a target appears on the screen once you'
%         'hit the starting dot' %Description for PostAdap-Gen
%         ' you need to do a fast and straight movement to hit the target'
%         ' The target position will randomly change between trials. '
%         ' You will not get any Feedback'
%         ' If you are ready, Press space key to continue'
%         
%         ' We will shortly begin another phase.' %Description for PostAdap-Retrain
%         ' In this phase, you will be asked to hit a white dot in several trials.'
%         ' Every trial starts with a white dot in middle of the screen'
%         ' As soon as you touch the starting position it will turn to green'
%         ' and at the same time you see a target on the right side with the same color (white)'
%         ' You need to draw a fast and straight line from middle dot to the target.'
%         ' A smaller dot will appear and represent your cursor as a feedback'
%         ' In the end of each trial, you will see a blue dot which shows your end point to modify your next movement'
%         ' If you are ready, Press space key to continue'
%         
%         ' In this phase, There is no Target to hit. You are free to choose any direction in first quadrant of the cricle (0-90 Deg)'%Description for PostAdap-Loc
%         ' You need to perform ballistic and fast movements'
%         ' You will not get any feedback. '
%         ' if you are ready, ask experimenter to press SPACE key to continue '};
    
elseif active_mode == 1
    
        L_1 = {' Wir werden in Kürze mit der Einarbeitungsphase beginnen.'% Familiarization (1st block in the PreAdaptation)
         ' Sie werden nun, in mehreren Versuchen, darum gebeten einen weißen Punkt zu treffen.'
         ' Jede Übung beginnt mit einem weißen Punkt in der Mitte des Bildschirmes '
         ' Sobald Sie die Startposition gefunden haben, färbt sich der Punkt grün'
         ' und im selben Moment werden Sie einen weiteren Zielpunkt in weiß sehen'
         ' Sie sollen nun eine schnelle und zielgerichtete Linie vom mittleren Punkt zum Zielpunkt ziehen.'
         ' Ein kleinerer Punkt wird erscheinen und Ihren Cursor anzeigen.'
         ' Am Ende jeder Bewegung werden Sie einen blauen Punkt sehen welcher' 
         'Ihre Endposition anzeigt um Ihre Bewegung ggf. anzupassen.'
         ' Teilen Sie uns mit wenn Sie bereit sind.'
    
         
         ' Ende der Einarbeitungsphase...'%Begining of Localization (2nd block in the PreAdaptation)
         ' In dieser Übung müssen Sie schnelle Bewegungen ausführen.'
         ' Es gibt keinen Zielpunkt. Sie können Ihre Hand frei im oberen rechten Bildschirmbereich in'
         ' einem 90° Winkel bewegen.'
         ' Sie werden keine Rückmeldung über Ihre Bewegung erhalten.'
         ' Dann werden Sie einen Kreis mit zahlen sehen und werden aufgefordert zu sagen '
         ' wo sich ihre Hand befindet '
         ' Wenn Sie "recording" lesen sagen Sie die Nummer laut.'
         ' Bitte merken Sie sich Ihre Bewegungen und variieren Sie diese.'
         ' Teilen Sie uns mit wenn Sie bereit sind.'
         
         ' Sehr gut! Jetzt beginnen wir mit einem anderen Test.'%Begining of Generalization (3rd block in the PreAdaptation)
         'In dieser Phase werden Sie einen Zielpunkt sehen,'
         'sobald Sie die Startposition gefunden haben.'
         ' Bitte versuchen Sie den Zielpunkt mit einer schnellen und Zielgerichteten'
         ' Bewegung zu treffen.  Die Position des Ziels wird zwischen den Experimenten zufällig variieren'
         ' Sie werden keine Rückmeldung bekommen.'
         ' Wenn Sie mögen, können Sie nun eine kleine Pause machen.'
         ' Teilen Sie uns mit wenn Sie bereit sind.'
         
         'WOrking memory Task'};
     
%      L_2 = { 'Bei jeder Übung, wird ein Zielpunkt erscheinen sobald Sie die Startposition'
%          'gefunden haben.'
%          'Sie sollen eine schnelle und zielgerichtete Bewegung zum Zielpunkt ausführen.'
%          'Die Position des Ziels wird zwischen den Experimenten zufällig variieren.'
%          'Sie werden keine Rückmeldung erhalten.'
%          'Teilen Sie uns mit wenn Sie bereit sind.'
%          
%          'Bei dieser Übung sollen Sie entweder den weißen Punkt treffen,' 
%          'oder eine Bewegung in einer selbst gewählten Richtung durchführen.'
%          'Am Beginn jeden Abschnitts sehen Sie entweder den Buchstaben Z, in diesem Fall'
%          'Wird die weiße Startposition grün werden, sobald Sie sie erreichen.'
%          'Gleichzeitig sehen Sie das weiße Ziel auf der rechten Seite des Bildschirms.'
%          'Sie sollen dann eine schnelle gerade Bewegung von der Mitte zu diesem Zielpunkt ausführen.'
%          'Ein kleiner Punkt erscheint und zeigt an, wo Sie sich gerade befinden.'
%          
%          'Oder Sie sehen einen blinkenden Kreis.'
%          'Dann führen Sie eine Bewegung zu einem frei gewählten Zielpunkt im'
%          'ersten Quadranten des Kreises aus.'
%          'Ihr Blick soll dabei auf dem Startpunkt bleiben.'
%          'Danach bringen Sie ihre Hand wieder zum unteren Rand des Bildschirms.'
%          'Sie sehen einen Kreis mit Zahlen und sollen die Zahl angeben, '
%          'bei der Ihre Bewegung den Kreis traf.'};
%          
%          'Wir werden in Kürze mit einer neuen Übung beginnen.'
%          'In dieser Übung werden Sie gebeten einen weißen Punkt in'
%          'mehreren Versuchen zu treffen.'
%          'Jede Übung beginnt mit einem weißen Punkt in der Mitte des Bildschirmes.'
%          'Sobald Sie die Startposition eingenommen haben, färbt sich der Punkt grün'
%          'und im selben Moment erscheint ein weißer Zielpunkt auf der rechten Seite'
%          'Sie sollen nun eine schnelle und zielgerichtete Linie vom mittleren Punkt zum'
%          'Zielpunkt ziehen.'
%          'Ein kleinerer Punkt wird erscheinen und repräsentiert Ihren Cursor als Rückmeldung.'
%          'Am Ende jeder Übung werden Sie einen blauen Punkt sehen, welcher Ihre Endposition anzeigt'
%          'um Ihre Bewegung ggf. anzupassen.'
%          'Teilen Sie uns mit wenn Sie bereit sind.'
%          
%          'Es gibt keinen Zielpunkt. Sie können Ihre Hand frei im oberen rechten Bildschirmbereich'
%          'in einem 90° Winkel bewegen.'
%          'Sie sollen eine zielgerichtete und schnelle Bewegungen ausführen'
%          'Sie werden keine Rückmeldung erhalten.'
%          'Teilen Sie uns mit wenn Sie bereit sind.'};
    %
end
end

%  'We will shortly begin the Experiment'
%     'During the whole experiment, you will be asked to either move your finger through a white target'
%     'OR'
%     'move your finger to an arbitrary direction between 9-12 O''clock'
%     'TARGET MOVEMENT'
%     'Every trial starts with a white dot in the middle of the screen.'
%     'When your finger is close to the starting position, a small dot appears that represents your actual finger''s position'
%     'As soon as your finger is within the starting position it will turn out to green,'
%     'and at the same time you see a target on the right side with the same color (white).'
%     'You need to draw a fast and straight line from middle dot to the target.'
%     'When your movement is finished, lift up your hand and be prepared for the next block.'
%     'Remember these are center-out reaches, meaning that every trial starts from the same starting position.'
%     'NO TARGET MOVEMENT'
%     'It always starts with a count down, after that you are free to choose any direction in the allowed direction.'
%     'You will not get any feedback on your finger''s location. When the movement phase is finished, you will go through another fixation phase.'
%     'Try to fixate on the fixation mark. The response phase initiates after count down and'
%     'you will see a graded circle that requires you to report where your hand passed the circle.'
%     'For the response phase, you have the control of button box in your left hand.'
%     'You have a limited time to go back and forth between the numbers and confirm your selected number with button ..'
%     'Please bear in mind to distribute your spatial movement directions'
%     'If you are ready, We will start the session...' 