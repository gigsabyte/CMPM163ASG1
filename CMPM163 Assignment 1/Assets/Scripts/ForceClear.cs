using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceClear : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void OnPreRender()
    {
        // why the fuck do i have to do this.
        GL.Clear(false, true, Color.clear);
    }
}
