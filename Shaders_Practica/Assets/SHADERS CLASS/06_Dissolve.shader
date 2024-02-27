Shader"ENTI/06_Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "WHITE" {}
        _MaskTexture ("Mask Texture", 2D) = "WHITE" {}
        _RevealValue ("Reveal Value", Range(0, 1)) = 1.0
        _FeatherValue ("Feather Value", float) = 1.0
        _NoiseScale ("Noise Scale", Range(1, 20)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
                float4 uv : TEXCOORD0;
};

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _MaskTexture_ST;
            sampler2D _MainTex, _MaskTexture;
            float _RevealValue, _FeatherValue, _NoiseScale;

            //NOISE FUNCTIONS-------------------------------------------------------------------------
            float2 unity_gradientNoise_dir(float2 p)
            {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            float unity_gradientNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(unity_gradientNoise_dir(ip), fp);
                float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }
            //NOISE FUNCTIONS-------------------------------------------------------------------------


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);             
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTexture);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 mask = tex2D(_MaskTexture, i.uv.zw);
    
                float noise = unity_gradientNoise(i.uv.zw * _NoiseScale);
    
                //1 Smooth Gradient Reveal
                //col = lerp(col, mask, revealAmountSmooth);
                //float revealAmountSmooth = smoothstep(mask.r - _FeatherValue, mask.r + _FeatherValue, _RevealValue);
    
                //2 Dissolve with a color
                float revealTop = step(noise, _RevealValue + _FeatherValue);
                float revealBot = step(noise, _RevealValue - _FeatherValue);
                float difference = revealTop - revealBot;
                fixed3 finalColor = lerp(col.rgb, _Color, difference);    
                
                return fixed4(finalColor.rgb, col.a * revealTop);
}
            ENDCG
        }
    }
}
