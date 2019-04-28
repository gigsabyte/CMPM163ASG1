/* 
 * Cellular automata shader based on the 313 rule by David Griffeath.
 * Algorithm referenced here: https://softologyblog.wordpress.com/2013/08/29/cyclic-cellular-automata/
 * Javascript implementation referenced: http://jsfiddle.net/awilliams47/LJnue/
 * Neighborhood array shamelessly stolen from RenderToTexture_CA by A. Forbes
 *
 */

Shader "Custom/CellAutomata"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Threshold("Threshold", int) = 3 // our threshold
		_Color0("Color 0", Color) = (1.0, 0.0, 1.0, 1.0) // magenta
		_Color1("Color 1", Color) = (1.0, 1.0, 0.0, 1.0) // yellow
		_Color2("Color 2", Color) = (0.0, 1.0, 1.0, 1.0) // cyan
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

			// moore neighborhood predicate function
			bool moorePred(float4 neighbors[8], float4 col, int threshold) {
				int ind = 0;
				if(threshold <= 1) { // if the threshold is 1
					while(ind < 8) { // return true if one neighbor is the color we're looking for
						if(neighbors[ind].r == col.r && neighbors[ind].g == col.g &&
						   neighbors[ind].b == col.b) return true;
						ind++;
					}
				}
				else { // if threshold > 1
					int weight = 0; // keep track of the weight
					while(ind < 8) { // increment weight if colors match
						if(neighbors[ind].r == col.r && neighbors[ind].g == col.g &&
						   neighbors[ind].b == col.b) weight++;
						ind++;
					}
					return(weight >= threshold); // return true if weight is >= threshold
				}
				return false; // default return false to stop the compiler from yelling at me
			}

			// function to round Float4s down to the nearest tenth place
			float4 roundFloat4(float4 col) {
				float4 rcol = col;
				rcol.r = floor(rcol.r * 10)/10;
				rcol.g = floor(rcol.g * 10)/10;
				rcol.b = floor(rcol.b * 10)/10;

				return rcol;
			}

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
			float4 _MainTex_TexelSize;
			int _Threshold;

			fixed4 _Color0;
			fixed4 _Color1;
			fixed4 _Color2;

            v2f vert (appdata v) // we're not messing with the verticies
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target // put we are messing with the frag shader
            {
				fixed4 cols[3]; // slap all the color options in an array for later
				cols[0] = _Color0;
				cols[1] = _Color1;
				cols[2] = _Color2;

				float2 texel = float2( // get our texel
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
                
                float cx = i.uv.x;
                float cy = i.uv.y;
                
                float4 C = tex2D( _MainTex, float2( cx, cy )); // get our texel color

				C = roundFloat4(C); // round it
				
				// match up the color to one of the 3 options to get its index
				int colIndex = 0;
				for(int ind = 0; ind < 3; ind++) {
					if(C.r == cols[ind].r && C.g == cols[ind].g && C.b == cols[ind].b) {
						colIndex = ind;
						break;
					}
				}
                
				// get the neighborhood
				// this code is from the RenderToTexture_CA shader
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

				// round all the neighbors
				for(int inde = 0; inde < 8; inde++) {
					arr[inde] = roundFloat4(arr[inde]);
				}

				// check if the next color is above the threshold
				if(colIndex == 2) C = cols[0];
				else C = cols[colIndex+1];
				if(moorePred(arr, C, _Threshold)) {
					if(colIndex == 2) return(cols[0]); // if it is, change to that color
					return cols[colIndex+1]; // then return it
				}
				return cols[colIndex]; // otherwise return the current color
            }
            ENDCG
        }
    }
}
