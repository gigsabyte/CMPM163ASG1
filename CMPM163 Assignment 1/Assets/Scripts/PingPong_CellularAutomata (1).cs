using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PingPong_CellularAutomata : MonoBehaviour
{
    Texture2D texA;
    Texture2D texB;
    //Texture2D inputTex;
    //Texture2D outputTex;
    RenderTexture rt1;
    RenderTexture rt2;

    Shader cellularAutomataShader;
    Shader ouputTextureShader;

    int width;
    int height;

    Renderer rend;
    int count = 0;

    void Start()
    {
        //print(SystemInfo.copyTextureSupport);

        width = 64;
        height = 64;

        texA = new Texture2D(width, height, TextureFormat.RGBA32, false);
        texB = new Texture2D(width, height, TextureFormat.RGBA32, false);

        texA.filterMode = FilterMode.Point;
        texB.filterMode = FilterMode.Point;

        for (int i = 0; i < height; i++)
            for (int j = 0; j < width; j++)
                if (Random.Range(0.0f, 1.0f) < 0.5)
                {
                    texA.SetPixel(i, j, Color.black);
                } else {
                    texA.SetPixel(i, j, Color.white);
                }

        texA.Apply(); //copy changes to the GPU


        rt1 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rt2 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rt1.filterMode = FilterMode.Point;
        rt2.filterMode = FilterMode.Point;


        rend = GetComponent<Renderer>();

        cellularAutomataShader = Shader.Find("Custom/RenderToTexture_CA");
        ouputTextureShader = Shader.Find("Custom/OutputTexture");

        rend.material.shader = cellularAutomataShader;
        Graphics.Blit(texA, rt1, rend.material);
        Graphics.Blit(texB, rt2, rend.material);
    }

   
    void Update()
    {
        //set active shader to be a shader that computes the next timestep
        //of the Cellular Automata system
        rend.material.shader = cellularAutomataShader;
      
        if (count % 2 == 0)
        {
            rend.material.SetTexture("_MainTex", rt1);
            Graphics.Blit(rt1, rt2, rend.material);
            rend.material.shader = ouputTextureShader;
            rend.material.SetTexture("_MainTex", rt2);
        }
        else
        {
            rend.material.SetTexture("_MainTex", rt2);
            Graphics.Blit(rt2, rt1, rend.material);
            rend.material.shader = ouputTextureShader;
            rend.material.SetTexture("_MainTex", rt1);

        }

        /*
        //source, destination, material
        //Graphics.Blit(inputTex, rt1, rend.material);
        //Graphics.CopyTexture(rt1, outputTex);


        //set the active shader to be a regular shader that maps the current
        //output texture onto a game object
        //rend.material.shader = ouputTextureShader;
        //rend.material.SetTexture("_MainTex", rt1);
        */

        count++;
    }
}
