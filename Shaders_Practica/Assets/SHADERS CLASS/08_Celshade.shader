Shader"ENTI/08_Celshade"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}


        [Space(1)]
        [Header(Ambient)]
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientIntensity("Ambient Intensity", Range(0.001, 5)) = 1.0

        [Space(1)]
        [Header(Diffuse)]
        _Attenuation ("Attenuation", Range(0.001, 5)) = 1.0

        [Space(1)]
        [Header(Specular)]
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecularPower("Specular Power", Range(1, 20)) = 1.0
        _SpecularIntensity("Specular Intensity", Range(0.001, 5)) = 1.0

        [Space(1)]
        [Header(Celshade)]
        _ShadowColor("Shadow Color", Color) = (1,1,1,1)
        _ShadowIntensity("Shadow Color", Range(0, 1)) = 1.0
        _CelThreshold("Celshade Threshold", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 uv : TEXCOORD0;
                float3 viewDirection : TEXCOORD1;
                float4 color : COLOR;
            };

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            fixed4 _Color, _SpecularColor, _ShadowColor;
            float _Attenuation, _AmbientIntensity, _SpecularIntensity, _SpecularPower, _CelThreshold, _ShadowIntensity;
            uniform float4 _LightColor0;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);         
    
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.viewDirection = normalize(WorldSpaceViewDir(v.vertex));
    
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                // Get light direction
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    
                //Diffuse reflection
                float3 diffuseReflection = dot(i.normal, lightDirection);
                diffuseReflection = max(0.0, diffuseReflection) * _Attenuation;
    
                //Celshade
                fixed light = step(_CelThreshold, diffuseReflection.r);
                light = lerp(_ShadowIntensity, fixed(1), light);
                fixed3 lightColor = lerp(_ShadowColor.rgb, _LightColor0.rgb, light);
    
                //Specular relfection
                float3 x = reflect(-lightDirection, i.normal);
                float3 specularReflection = dot(x, i.viewDirection);
                specularReflection = pow(max(0.0, specularReflection), _SpecularPower) * _SpecularIntensity;
                //BLINN-PHONG
                half3 halfDirection = normalize(lightDirection + i.viewDirection);
                float specularAngle = max(0.0, dot(halfDirection, i.normal));
                specularReflection = pow(specularAngle, _SpecularPower) * _SpecularIntensity;
                //
                specularReflection *= diffuseReflection;
                specularReflection *= _SpecularColor.rgb;
                    
                float3 lightFinal = lightColor;
                // Use ambient light
                //lightFinal += UNITY_LIGHTMODEL_AMBIENT.rgb;
    
                // Use custom ambient ligh
                lightFinal += _Color.rgb * _AmbientIntensity;
                lightFinal += specularReflection;
    
                i.color = float4(lightFinal, 1.0);
    
                return i.color;
            }
            ENDCG
        }
    }
}
