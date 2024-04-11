using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class PostEffectController : MonoBehaviour
{

    [SerializeField] private Shader _postProcessing;
    private Material _postEffectMaterial;

    [SerializeField] private Color _screenTint;
    [SerializeField] private float _pixelate;
    [SerializeField] private float _radius;
    [SerializeField] private float _feather;
    [SerializeField] private Color _vignetteColor;

    private Camera _camera;

    private void Start()
    {
        _camera = GetComponent<Camera>();
        _camera.depthTextureMode = _camera.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_postEffectMaterial == null)
        {
            _postEffectMaterial = new Material(_postProcessing);
        }

        //SCREEN TINT
        _postEffectMaterial.SetColor("_ScreenTint", _screenTint);
        RenderTexture endRenderTexture = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(source, endRenderTexture, _postEffectMaterial, 0);
        RenderTexture temporaryFirstRenderTexure = source;
        RenderTexture temporarySecondRenderTexure = endRenderTexture;

        //PIXELATE
        _postEffectMaterial.SetFloat("_ScreenXSize", source.width);
        _postEffectMaterial.SetFloat("_ScreenYSize", source.height);
        _postEffectMaterial.SetFloat("_Pixelate", _pixelate);
        endRenderTexture = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(temporarySecondRenderTexure, endRenderTexture, _postEffectMaterial, 1);
        temporaryFirstRenderTexure = endRenderTexture;

        //VIGNETTE
        _postEffectMaterial.SetFloat("_Radius", _radius);
        _postEffectMaterial.SetFloat("_Feather", _feather);
        _postEffectMaterial.SetColor("_VignetteColor", _vignetteColor);
        endRenderTexture = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        Graphics.Blit(temporaryFirstRenderTexure, destination, _postEffectMaterial, 2);
    }
}