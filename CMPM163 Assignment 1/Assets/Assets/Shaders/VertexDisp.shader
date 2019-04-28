Shader "Custom/VertexDisp"
{
    Properties
    {
		_Color ("Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
		_Shininess("Shininess", Float) = 1.0
		_AmbientColor("Ambient Color", Color) = (0.1, 0.1, 0.1, 1)
    }
    SubShader
    {
        Pass
        {
			Tags { "LightMode" = "ForwardAdd"}
			Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			float4 _Color;
			float4 _SpecularColor;
			float _Shininess;
			sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _LightColor0;
			float4 _AmbientColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal: NORMAL; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 vertInWorldCoords: TEXCOORD1;
				float3 normal: NORMAL;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.x += (sin(_Time.y - length(_WorldSpaceCameraPos.yz - o.vertex.yz)) + 1)/2;

				o.vertInWorldCoords = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 Ka = tex2D(_MainTex, i.uv);
                float3 globalAmbient = _AmbientColor.rgb;
                float3 ambientComponent = Ka * globalAmbient;

                float3 P = i.vertInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 Kd = Ka;
                float3 lightColor = _LightColor0.rgb;
                float3 diffuseComponent = Kd * lightColor * max(dot(N, L), 0);
                
                float3 Ks = Ka;
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 H = normalize(L + V);
                float3 specularComponent = Ks * lightColor * pow(max(dot(N, H), 0), _Shininess);
                
                
                float3 finalColor = ambientComponent + diffuseComponent + specularComponent;
                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
