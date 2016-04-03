/**
 * Created by The Matrix on 4/3/2016.
 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import g4p_controls.*;
//import processing.sound.*;
import ddf.minim.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Sequencer extends PApplet {


// import libraries


    Minim minim;
    AudioPlayer f1;
    AudioPlayer f2;
    AudioPlayer f3;
    AudioPlayer f4;
    AudioPlayer f5;
    AudioPlayer f6;
    AudioPlayer f7;
    AudioPlayer f8;
    // define global variables
    int MyDispX = 800; // set the size of our display window
    int MyDispY = 360;
    int startX = 20;
    int startY = 20;
    int curX = startX;
    int curY = startY;
    int bpmLocX = MyDispX - 100;
    int bpmLocY = 50;
    int curPos = 0;
    int bg = 255;
    int myBPM = 120; // beats per minute
    int tempo = 1000 * 60/myBPM;
    int mytime = 0;
    GTimer GT1; // we get the GTimer from the G4P library
    boolean rectOver[] = new boolean[129]; // apparently, with my indexing of the array, I needed one more cell to prevent crashing
    int rectX[] = new int[128]; //arays for rectangle postions
    int rectY[] = new int[128];
    int rectSpacing = 40; // distance between rectangles
    int rectSize = 25;     // size of rect
    int rectColor; // ordinary rectangle colour
    int rectHighlight; // highlight colour
    //color currentColor; // current colour, whatever that may be
    int btnID = -1; // keep track of what button we're over
    boolean playing = false;

    // in Processing 3, some system definitions can only be changed, using variables, in a settings function
    public void settings()
    {
        size(MyDispX, MyDispY);
    }

    // teh setup function, runs once when the program starts
    public void setup() {
        int i,j;
        background(bg);
        frameRate(30);
        // Load a soundfile from the /data folder of the sketch and play it back

        minim = new Minim(this);
        f1 = minim.loadFile("2.mp3");
        f2 = minim.loadFile("3.mp3");
        f3 = minim.loadFile("4.mp3");
        f4 = minim.loadFile("5.mp3");
        f5 = minim.loadFile("6.mp3");
        f6 = minim.loadFile("7.mp3");
        f7 = minim.loadFile("8.mp3");
        f8 = minim.loadFile("9.mp3");

        GT1 = new GTimer(this, this, "showtime", tempo);
        // GT1.start(); // commented out, as we're starting and stopping with space bar now.
        rectColor = 0xff555555;
        rectHighlight = 0xffFFFF00;
        textFont(createFont("Georgia", 24));


        for(i=0;i<128;i++)
        {
            rectOver[i] = false;
        }
        // calculate all rectangle coordinates
        for(i=0;i<8;i++) // rows
        {
            for(j=0;j<16;j++) // columns
            {
                rectX[(i*16) + j] = curX;
                rectY[(i*16) + j] = curY;
                curX += rectSpacing;
                // check if we've filled one row
                if(j == 15)
                {
                    curX = startX;
                }
            }
            curY += rectSpacing;
        }
    }

    // the main draw function. This is the function called for every frame refresh
    public void draw()
    {
        update(mouseX, mouseY);
        background(bg);
        playCursor();
        drawSquares();
        showbpm(myBPM);
    }

// everything below this point are functions that make up the rest of te functionality

    // a cursor that indicates where we are on screen and in the sequence
    public void playCursor()
    {
        stroke( 50, 50 , 50);
        strokeWeight(4);
        line(curPos, 0, curPos, MyDispY);
    }

    // check if the cursor is over a particuar area
    public boolean overRect(int x, int y, int width, int height)  {
        if (mouseX >= x && mouseX <= x+width &&
                mouseY >= y && mouseY <= y+height) {
            return true;
        } else {
            return false;
        }
    }

    // update what button we're over
    public void update(int x, int y)
    {
        int i,j;
        for(i=0;i<8;i++)
        {
            for(j=0;j<16;j++)
            {
                if ( overRect(rectX[(i*16) + j], rectY[(i*16) + j], rectSize, rectSize) )
                {
                    btnID = (i*16) + j;
                }
            }
        }
    }

    // pick the notes that are active for the beat we're on
    public void soundstep(int n)
    {
        if(rectOver[n] == true)
        {
            f1.play();
        }
        if(rectOver[n+16] == true)
        {
            f2.play();
        }
        if(rectOver[n+32] == true)
        {
            f3.play();
        }
        if(rectOver[n+48] == true)
        {
            f4.play();
        }
        if(rectOver[n+64] == true)
        {
            f5.play();
        }
        if(rectOver[n+80] == true)
        {
            f6.play();
        }
        if(rectOver[n+96] == true)
        {
            f7.play();
        }
        if(rectOver[n+112] == true)
        {
            f8.play();
        }
    }
    // handle mouse clicks
    public void mouseClicked()
    {
//  println(btnID);
        if(btnID != -1)
        {
            if(rectOver[btnID] == false)
            {
                rectOver[btnID] = true;
                //print("Button: ");
                //println(btnID);
            }
            else
            {
                rectOver[btnID] = false;
            }
        }
    }

    // check if the user is pressing keys
    public void keyPressed()
    {
        switch(key)
        {
            // exit the program
            case ESC:
                GT1.stop();
                stop();
                exit();
                break;
            // arrow keys for changing tempo
            case CODED:
                if( keyCode == UP)
                {
                    myBPM++;
                    tempo = 1000 * 60/myBPM;
                    GT1.setInterval(tempo);
                }
                if( keyCode == DOWN)
                {
                    myBPM--;

                    if(tempo<0)
                    {
                        tempo = 0;
                    }
                    tempo = 1000 * 60/myBPM;
                    GT1.setInterval(tempo);
                }
                //print(myBPM);
                //print(" ");
                //println(tempo);
                break;
            // letter keys for playing sound directly
            case ' ': // start/stop playing when pressing SPACE bar
                if(playing == false)
                {
                    playing = true;
                    GT1.start();
                }
                else
                {
                    GT1.stop();
                    playing = false;
                }
                break;
            case ENTER:
                mytime = 0;
                break;
            case RETURN:
                mytime = 0;
                break;
            case 'a':
                f1.play();
                break;
            case 's':
                f2.play();
                break;
            case 'd':
                f3.play();
                break;
            case 'f':
                f4.play();
                break;
            case 'g':
                f5.play();
                break;
            case 'h':
                f6.play();
                break;
            case 'j':
                f7.play();
                break;
            case 'k':
                f8.play();
                break;
            default:
                break;
        }

    }

    // draw all the squares on screen
    public void drawSquares()
    {
        int i,j;
        strokeWeight(1); // draw thin lines around rectangles
        for(i=0;i<16;i++)
        {
            for(j=0;j<8;j++)
            {
                if(rectOver[(i*8) + j])
                {
                    fill(rectHighlight);
                }
                else
                {
                    fill(rectColor);
                }
                stroke(0xffFF0000);
                rect(rectX[(i*8) + j], rectY[(i*8) + j], rectSize, rectSize);
            }
        }
    }

    // display BPM value
    public void showbpm( int i )
    {
        textAlign(LEFT);
        fill(0);
        text("Tempo", bpmLocX, bpmLocY);
        text(i, bpmLocX, bpmLocY + rectSpacing);
    }

    // timer for each beat, runs as callback
    public void showtime(GTimer gtimer)
    {
        mytime++;
        if(mytime > 16)
        {
            mytime = 1;
        }
        soundstep(mytime - 1);
        curPos = (mytime - 1) * rectSpacing + rectSize/2 + startX;
//  println(mytime);
    }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "Sequencer" };
        if (passedArgs != null) {
            PApplet.main(concat(appletArgs, passedArgs));
        } else {
            PApplet.main(appletArgs);
        }
    }
}
