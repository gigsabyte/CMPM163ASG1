/* 
 * Companion script for the CellAutomata shader.
 * Most of this is taken from PingPong_CellularAutomata.cs
 * OutputTexture.shader is also used because there's no real point in re-writing it.
 * 
 */

using UnityEngine;

public class CellAutomata : MonoBehaviour
{
    // textures
    Texture2D texA;
    Texture2D texB;
    RenderTexture rt1;
    RenderTexture rt2;

    // shaders
    Shader cellularAutomataShader;
    Shader ouputTextureShader;

    // width and height of our textures
    int width;
    int height;

    Renderer rend; // renderer
    int count = 0; // frame count

    Color[] colors; // color array

    // Start is called before the first frame update
    void Start()
    {
        rend = GetComponent<Renderer>(); // get our renderer
        cellularAutomataShader = Shader.Find("Custom/CellAutomata"); // and our cell automata shader
        rend.material.shader = cellularAutomataShader; // set the renderer's shader to ^

        // fill up our color array from our shader
        colors = new Color[3];
        for(int i = 0; i < colors.Length; i++)
        {
            string name = "_Color" + i;
            colors[i] = rend.material.GetColor(name);
            
        }

        // we're making a 128px square texture because bigger sizes take too long
        width = 256;
        height = 256;

        texA = new Texture2D(width, height, TextureFormat.RGBA32, false);
        texB = new Texture2D(width, height, TextureFormat.RGBA32, false);

        texA.filterMode = FilterMode.Point;
        texB.filterMode = FilterMode.Point;

        float colorStep = 1.0f / 3;
        float rand = Random.Range(0.0f, 1.0f);        

        // populate our texture with random pixels
        for (int i = 0; i < height; i++)
        {
            for (int j = 0; j < width; j++)
            {
                rand = Random.Range(0.0f, 1.0f);
                Debug.Log(rand);
                if (rand < colorStep)
                {
                    texA.SetPixel(i, j, colors[0]);
                }
                else if (rand < colorStep * 2)
                {
                    texA.SetPixel(i, j, colors[1]);
                }
                else
                {
                    texA.SetPixel(i, j, colors[2]);
                }
            }
        }


        texA.Apply(); //copy changes to the GPU


        rt1 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rt2 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rt1.filterMode = FilterMode.Point;
        rt2.filterMode = FilterMode.Point;

        ouputTextureShader = Shader.Find("Custom/OutputTexture"); // get the outputtexture shader

        Graphics.Blit(texA, rt1, rend.material);
        Graphics.Blit(texB, rt2, rend.material);
    }

    // Update is called once per frame
    void Update()
    {
        //set active shader to be a shader that computes the next timestep
        //of the Cellular Automata system
        rend.material.shader = cellularAutomataShader;
        
        // reset the colors just in case
        rend.material.SetColor("_Color0", colors[0]);
        rend.material.SetColor("_Color1", colors[1]);
        rend.material.SetColor("_Color2", colors[2]);

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


        count++;
    }
}
