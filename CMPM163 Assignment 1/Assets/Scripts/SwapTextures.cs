using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwapTextures : MonoBehaviour
{
    [SerializeField]
    Texture[] textures = new Texture[8];

    Material mat;

    int index = 0;

    float intensity = 2.0f;

    // Start is called before the first frame update
    void Start()
    {
        mat = gameObject.GetComponent<Renderer>().material;
        mat.mainTexture = textures[index];
    }

    // Update is called once per frame
    void Update()
    {
        // swapping textures fun
        if(Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D))
        {
            index++;
            if(index >= textures.Length)
            {
                index = 0;
            }
            mat.mainTexture = textures[index];
        }
        else if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A))
        {
            index--;
            if (index < 0)
            {
                index = textures.Length -1;
            }
            mat.mainTexture = textures[index];
        }

        // changing intensity
        if (Input.GetKey(KeyCode.UpArrow) || Input.GetKey(KeyCode.W))
        {
            intensity++;
            if (intensity > 80) intensity = 80;
            mat.SetFloat("_Intensity", intensity);
        }
        else if (Input.GetKey(KeyCode.DownArrow) || Input.GetKey(KeyCode.S))
        {
            intensity--;
            if (intensity < 0) intensity = 0;
            mat.SetFloat("_Intensity", intensity);
        }
    }
}
