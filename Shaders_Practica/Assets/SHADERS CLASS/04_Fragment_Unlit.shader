Shader"ENTI/04_Fragment_Unlit"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _Blend ("Blend", Range(0, 1)) = 1.0
        _MainTex ("Main Texture", 2D) = "WHITE" {}
        _SecondTexture("Second Texture", 2D) = "WHITE" {}
        _ThirdTexture("Third Texture", 2D) = "WHITE" {}
        _BlendTexture ("Blend Texture", 2D) = "WHITE" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

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

            fixed4 _Color1;
            fixed4 _Color2;
            float _Blend;
            sampler2D _MainTex, _SecondTexture, _ThirdTexture, _BlendTexture;
            float4 _MainTex_ST, _SecondTexture_ST, _ThirdTexture_ST, _BlendTexture_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);   
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 col;
    
                //1 Blending
                col = _Color1 + _Color2 * _Blend;
    
                //2 Interpolation
                col = _Color1 * (1 - _Blend) + _Color2 * _Blend;
                col = lerp(_Color1, _Color2, _Blend);
    
                //3 Textures
                //Calculate UV Coordinates
                float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
                float2 second_uv = TRANSFORM_TEX(i.uv, _SecondTexture);
                float2 third_uv = TRANSFORM_TEX(i.uv, _ThirdTexture);
                //Read colors from texture
                fixed4 main_color = tex2D(_MainTex, main_uv);
                fixed4 second_color = tex2D(_SecondTexture, second_uv);
                fixed4 third_color = tex2D(_ThirdTexture, third_uv);
                //Interpolate
                float2 blend_uv = TRANSFORM_TEX(i.uv, _BlendTexture);
                fixed4 blend_color = tex2D(_BlendTexture, blend_uv);
    
                //col = lerp(main_color, second_color, blend_color.r);
                col = _Color1;
                col = lerp(col, main_color, blend_color.r);
                col = lerp(col, second_color, blend_color.g);
                col = lerp(col, third_color, blend_color.b);
    
                float sin_value = sin(_Time.y);
                sin_value = saturate(sin_value);
                sin_value = frac(sin_value);
                col = lerp(_Color1, _Color2, sin_value);
    
                return col;
            }
            ENDCG
        }
    }
}
