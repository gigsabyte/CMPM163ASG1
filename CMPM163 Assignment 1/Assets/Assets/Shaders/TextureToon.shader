
Shader "Custom/TextureToon"
{
    Properties
    {   
		_MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1) //The color of our object
        _Shininess ("Shininess", Float) = 32 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
		_AmbColor("Ambient Light Color", Color) = (0, 0, 0, 0) // Custom ambient light color
		_StepVal("Fuzziness", Range(0.1, 25)) = 2.0 // Custom stepval to make the toon shader "fuzzy"
    }
    
    SubShader
    {
		Tags { "LightMode" = "ForwardAdd" "RenderType"="Opaque"}
        Pass {
            Blend SrcAlpha SrcAlpha
			//Blend One One  // Blend One One //Turn on additive blending if you have more than one point light
			//BlendOp Max

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
			sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float4 _LightColor0; //From UnityCG
            uniform float4 _Color; 
			uniform float4 _AmbColor;
            uniform float4 _SpecColor;
            uniform float _Shininess;
			uniform float _StepVal;
          
            struct appdata
            {
                    float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
            };

            struct v2f
            {
					float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 normalInWorldCoords : NORMAL;       
                    float3 vertexInWorldCoords : TEXCOORD1;
            };

 
           v2f vert(appdata v)
           { 
                v2f o;
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
                o.normalInWorldCoords = UnityObjectToWorldNormal(v.normal); //Normal in WORLD coords
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
              
                return o;
           }

           fixed4 frag(v2f i) : SV_Target
           {
                
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normalInWorldCoords);
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);
                
                float3 Kd = tex2D(_MainTex, i.uv); //Color of object
                float3 Ka = _AmbColor.rgb; //Ambient light
                float3 Ks = _SpecColor.rgb; //Color of specular highlighting
                float3 Kl = _LightColor0.rgb; //Color of light
                
                
                const float A = 0.3; //0.5;
                const float B = 0.6; //1.0;
                const float C = 0.9;
                
                
                //AMBIENT LIGHT 
                float3 ambient = Ka;
                
               
              
                //DIFFUSE LIGHT
                float diffuseVal = max(dot(N, L), 0);
                float lightIntensity = diffuseVal;
                
                
                float stepVal = _StepVal/100;
                
                /*
                //Cel shading
                 if (diffuseVal < A) diffuseVal = A;
                 else if (diffuseVal < B) diffuseVal = B;
                 else if (diffuseVal < C) diffuseVal = C;
                 else diffuseVal = 1.0;
                 lightIntensity = diffuseVal;
                 */
                 
                 
                 
                 //Cel shading with smoothstep (emulating transitions between color values in a 1d texture ramp)
                 
                 
                 
                 if (diffuseVal >= 0 && diffuseVal < stepVal) diffuseVal = 0 + A * smoothstep(0, stepVal, diffuseVal);
                 else if (diffuseVal < A) diffuseVal = A;
                 else if (diffuseVal >= A && diffuseVal < A+stepVal) diffuseVal = A + (B-A) * smoothstep(A, A+stepVal, diffuseVal);
                 else if (diffuseVal < B) diffuseVal = B;
                 else if (diffuseVal >= B && diffuseVal < B+stepVal) diffuseVal = B + (C-B) * smoothstep(B, B+stepVal, diffuseVal);
                 else if (diffuseVal < C) diffuseVal = C;
                 else if (diffuseVal >= C && diffuseVal < C+stepVal) diffuseVal = C + (1.0 - C) * smoothstep(C, C+stepVal, diffuseVal);
                 else diffuseVal = 1.0; 
                 
                 
                 lightIntensity = diffuseVal; 
                 float3 diffuse = Kd * Kl * lightIntensity;
                
                
                //SPECULAR LIGHT
                float specularVal = pow(max(dot(N,H), 0), _Shininess);
                
                if (diffuseVal <= 0) {
                    specularVal = 0;
                }
                
                specularVal = smoothstep(0.25, 0.25 + stepVal, specularVal);
                float3 specular = Ks * Kl * specularVal;
                
                //FINAL COLOR OF FRAGMENT
                return float4(ambient + diffuse + specular, 0.6);
                

            }
            
            ENDCG
 
            
        }
            
    }
}
