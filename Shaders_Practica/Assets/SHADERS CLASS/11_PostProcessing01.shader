Shader"ENTI/11_PostProcessing01"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
    }

    CGINCLUDE

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

    v2f vert(appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass //0
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _ScreenTint;

            fixed4 frag (v2f i) : SV_Target
            {          
                fixed4 color = tex2D(_MainTex, i.uv);
                return color * _ScreenTint;
            }
            ENDCG
        }

        Pass //1
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _ScreenXSize;
            float _ScreenYSize;
            float _Pixelate;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 N = float2(_ScreenXSize / _Pixelate, _ScreenYSize / _Pixelate);
                i.uv = floor(i.uv * N) / N;
                fixed4 color = tex2D(_MainTex, i.uv);
                return color;
            }
            ENDCG
        }

        Pass //2
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _Radius;
            float _Feather;
            fixed4 _VignetteColor;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 centerUv = i.uv * 2 - 1;
                float circle = length(centerUv);
                float mask = smoothstep(_Radius, _Radius + _Feather, circle);
                fixed4 color = tex2D(_MainTex, i.uv);
                color.rgb = lerp(color.rgb, _VignetteColor, saturate(mask));
                return color;
            }
            ENDCG
        }
    }
}
