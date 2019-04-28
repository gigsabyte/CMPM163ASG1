/* 
 * Edge detection shader following the Sobel operator https://en.wikipedia.org/wiki/Sobel_operator
 * Used the following GLSL example as reference for implementation https://www.shadertoy.com/view/Xdf3Rf
*/

Shader "Custom/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (0, 0, 0, 0)
		_FillColor("Fill Color", Color) = (1, 1, 1, 1)
		_Intensity("Intensity", float) = 2.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			float4 _MainTex_TexelSize;
			float4 _EdgeColor;
			float4 _FillColor;
			float _Intensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
				float2 texel = float2(
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
                
                float cx = i.uv.x;
                float cy = i.uv.y;
                
                float4 C = tex2D( _MainTex, float2( cx, cy ));   
                
                float up = i.uv.y + texel.y * 1;
                float down = i.uv.y + texel.y * -1;
                float right = i.uv.x + texel.x * 1;
                float left = i.uv.x + texel.x * -1;
                
                float4 arr[8];

				arr[0] = tex2D(  _MainTex, float2( cx   , up ));   //N
                arr[1] = tex2D(  _MainTex, float2( right, up ));   //NE
                arr[2] = tex2D(  _MainTex, float2( right, cy ));   //E
                arr[3] = tex2D(  _MainTex, float2( right, down )); //SE
                arr[4] = tex2D(  _MainTex, float2( cx   , down )); //S
                arr[5] = tex2D(  _MainTex, float2( left , down )); //SW
                arr[6] = tex2D(  _MainTex, float2( left , cy ));   //W
                arr[7] = tex2D(  _MainTex, float2( left , up ));   //NW

				// Sobel operator

				float intn = _Intensity;

				//     +1   0  -1
				// Gx =+2   0  -2
				//     +1   0  -1
				             // 1 * NW               // -1 * NE                       
				float Gx = (1 * length(arr[7])) + (-1 * length(arr[1])) + 
				           // 2 * W               // -2 * E 
						   (2 * intn *length(arr[6])) + (-2 * intn *length(arr[2])) + 
						   // 1 * SW           // -1 * SE
						   (1 * length(arr[5])) + (-1 * length(arr[3])); 

				//     +1  +2  +1
				// Gy = 0   0   0
				//     -1  -2  -1
				             // 1 * NW               // 2 * N                        
				float Gy = (1 * length(arr[7])) + (2 * intn * length(arr[0])) + 
							// 1 * NW               // -1 * SW
						   (1 * length(arr[7])) + (-1 * length(arr[5])) + 
						   // -2 * S           // 1 * SE
						   (-2 * intn * length(arr[4])) + (-1 * length(arr[3])); 

				float G = sqrt((Gx*Gx) + (Gy*Gy));
				
				col = lerp(_FillColor, _EdgeColor, G);

                return col;
            }
            ENDCG
        }
    }
}
