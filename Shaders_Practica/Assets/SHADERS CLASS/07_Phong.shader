Shader"ENTI/07_Phong"
{
    Properties
    {
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
};

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
};

            fixed4 _Color, _SpecularColor;
            float _Attenuation, _AmbientIntensity, _SpecularIntensity, _SpecularPower;
            uniform float4 _LightColor0;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);         
    
                float3 viewDirection = normalize(WorldSpaceViewDir(v.vertex));
                // Get normal direction
                float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                // Get light direction
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    
                //Diffuse reflection
                float3 diffuseReflection = dot(normalDirection, lightDirection);
                diffuseReflection = max(0.0, diffuseReflection) * _Attenuation;
    
                //Specular relfection
                float3 x = reflect(-lightDirection, normalDirection);
                float3 specularReflection = dot(x, viewDirection);
                specularReflection = pow(max(0.0, specularReflection), _SpecularPower) * _SpecularIntensity;
                specularReflection *= diffuseReflection;
                specularReflection *= _SpecularColor.rgb;
    
    
                float3 lightFinal = diffuseReflection * _LightColor0.rgb;
                // Use ambient light
                //lightFinal += UNITY_LIGHTMODEL_AMBIENT.rgb;
    
                // Use custom ambient ligh
                lightFinal += _Color.rgb * _AmbientIntensity;
                lightFinal += specularReflection;
    
                o.color = float4(lightFinal, 1.0);
    
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                return i.color;
            }
            ENDCG
        }
    }
}
