using System;
using UnityEngine;

public class Health : MonoBehaviour
{
    public float Current;
    public float Max;
    public event Action Changed;

    private void Awake()
    {
        ResetHp();
    }

    private void ResetHp() => 
        Current = Max;

    public void GetHit(float hit)
    {
        Current -= hit;
        Changed?.Invoke();
    }

    public bool IsAlive() => Current > 0;
}