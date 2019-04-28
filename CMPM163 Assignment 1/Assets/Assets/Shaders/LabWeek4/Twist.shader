//Adapted for Unity from GLSL code at http://www.ozone3d.net/tutorials/mesh_deformer_p3.php

Shader "Custom/Twist"
{
    Properties
    {
        _Speed ("Speed", Float) = 1.0
        _Twistiness ("Twistiness", Float) = 1.0
    }
    SubShader
    {
     
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
           
            uniform float _Speed;
            uniform float _Twistiness;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;  
                float3 normal : NORMAL;
                
            };
            
            
         
            v2f vert (appdata v)
            {
                v2f o;
                
                const float PI = 3.14159;
                
                float rad = sin(_Time.y * _Speed);
                
                float useTwist = 10.0;
                
                if (_Twistiness >= 10.0) {
                    useTwist = 0.01;
                } else if (_Twistiness <= 0.0) {
                    useTwist = 10;    
                } else {
                    useTwist = 10 - _Twistiness;
                }
                
                float ct = cos(v.vertex.y/useTwist);
                float st = sin(v.vertex.y/useTwist);
               
                float newx = v.vertex.x + (v.vertex.x * ct * rad - v.vertex.z * st * rad ); 
                float newz = v.vertex.z + (v.vertex.x * st * rad + v.vertex.z * ct * rad ); 
                float newy = v.vertex.y ;
                
                float4 xyz = float4(newx, newy, newz, 1.0);
                
                o.vertex = UnityObjectToClipPos(xyz);
                o.normal = v.normal;
                
                return o;
            }

            float4 normalToColor (float3 n) {
                return float4( (normalize(n) + 1.0) / 2.0, 1.0) ;
            }
           

            fixed4 frag (v2f i) : SV_Target
            {
                return normalToColor(i.normal);
            }
       
            ENDCG
        }
    }
}
