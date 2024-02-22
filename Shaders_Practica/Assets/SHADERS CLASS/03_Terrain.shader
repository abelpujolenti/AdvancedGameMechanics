Shader"ENTI/03_Terrain"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Heatmap("Heatmap", 2D) = "white" {}
        _MaxHeight("Max Height", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Heatmap;
            float4 _Heatmap_ST;
            fixed4 _Color;
            float _MaxHeight;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                            //o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                            ////A
                            //o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
                            ////B
                            //o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                            //o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                            //float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                            //o.uv = TRANSFORM_TEX(worldPos.xz, _MainTex);

                float2 local_tex_Height = tex2Dlod(_MainTex, float4(v.uv, 0, 0));
                float l_Height = local_tex_Height.y * _MaxHeight;
                o.uv = float2(v.uv.x, local_tex_Height.y);

                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex.y = o.vertex.y + l_Height;
                o.vertex = mul(UNITY_MATRIX_VP, o.vertex);

                            //o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_Heatmap, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
/*Shader"ENTI/03_Terrain"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "WHITE" {}
        _MaxHeight ("Max Height", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MaxHeight;

            v2f vert (appdata v)
            {
                v2f o;     
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex = mul(unity_ObjectToWorld, v.vertex);
                ////Option A
                //o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
                ////Option B
                //o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                //o.vertex = mul(UNITY_MATRIX_P, o.vertex);
    
                //float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
                float2 local_texture_height = tex2Dlod(_MainTex, float4(v.uv, 0, 0));
                float l_height = local_texture_height.y * _MaxHeight;
                o.uv = float2(v.uv.x, local_texture_height.y);
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                //o.uv = TRANSFORM_TEX(worldPosition.xz, _MainTex);
                o.vertex.y += l_height;
                o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}*/
