# Configuración de la Tabla User_login - ACTUALIZADO

## 📋 Estructura de tu Tabla

Tu tabla `User_login` tiene la siguiente estructura:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | bigint | ID autoincremental (PRIMARY KEY) |
| `first_name` | varchar | Nombre del usuario |
| `last_name` | varchar | Apellido del usuario |
| `date_of_birth` | date | Fecha de nacimiento |
| `email` | varchar | Correo electrónico |
| `password_hash` | varchar | Hash de contraseña (NULL - manejado por Supabase Auth) |
| `status` | **boolean** | Estado del usuario (true = activo, false = inactivo) |
| `created_at` | timestamp | Fecha de creación |
| `updated_at` | timestamp | Fecha de última actualización |

## ⚠️ IMPORTANTE: Configurar Valores por Defecto

Para que la inserción funcione correctamente, ejecuta este script en **SQL Editor** de Supabase:

```sql
-- Configurar valores por defecto para User_login
ALTER TABLE public.User_login 
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW(),
  ALTER COLUMN status SET DEFAULT true,
  ALTER COLUMN password_hash DROP NOT NULL; -- Permitir NULL

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.User_login ENABLE ROW LEVEL SECURITY;

-- Política: Permitir INSERT para usuarios autenticados
CREATE POLICY "Users can insert their own data"
  ON public.User_login 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

-- Política: Los usuarios pueden ver solo su propia información
CREATE POLICY "Users can view their own data"
  ON public.User_login 
  FOR SELECT 
  TO authenticated
  USING (email = auth.jwt()->>'email');

-- Política: Los usuarios pueden actualizar solo su propia información
CREATE POLICY "Users can update their own data"
  ON public.User_login 
  FOR UPDATE 
  TO authenticated
  USING (email = auth.jwt()->>'email')
  WITH CHECK (email = auth.jwt()->>'email');

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_login_updated_at ON public.User_login;
CREATE TRIGGER update_user_login_updated_at
  BEFORE UPDATE ON public.User_login
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_updated_at_column();
```

## 🔄 Cómo Funciona la Inserción

Cuando un usuario se registra, la app inserta:

```dart
await supabase.from('User_login').insert({
  'first_name': 'Juan',
  'last_name': 'Pérez',
  'date_of_birth': '2000-01-15',  // Formato: YYYY-MM-DD
  'email': 'juan@example.com',
  'status': true,  // Boolean: true = activo
});
```

**Campos que se llenan automáticamente:**
- `id`: Autoincremental
- `created_at`: NOW() por defecto
- `updated_at`: NOW() por defecto
- `password_hash`: NULL (Supabase Auth maneja las contraseñas)

## ✅ Verificar que Funciona

Después de registrar un usuario, ejecuta en **SQL Editor**:

```sql
SELECT 
  id,
  first_name,
  last_name,
  date_of_birth,
  email,
  status,
  created_at,
  updated_at
FROM public.User_login 
ORDER BY created_at DESC 
LIMIT 5;
```

Deberías ver el nuevo usuario con:
- ✅ `first_name` y `last_name` llenos
- ✅ `date_of_birth` con la fecha seleccionada
- ✅ `email` con el correo registrado
- ✅ `status` = `true`
- ✅ `created_at` y `updated_at` con la fecha/hora actual
- ⚠️ `password_hash` = `NULL` (esto es correcto)

## 🚨 Troubleshooting

### Error: "new row violates row-level security policy"
**Solución**: Ejecuta las políticas RLS del script SQL arriba.

### Error: "null value in column violates not-null constraint"
**Solución**: Verifica que `password_hash` permita NULL:
```sql
ALTER TABLE public.User_login 
  ALTER COLUMN password_hash DROP NOT NULL;
```

### Error: "invalid input syntax for type boolean"
**Solución**: Ya está arreglado - ahora enviamos `true` (boolean) en lugar de `'active'` (string).

### Los usuarios no aparecen en la tabla
**Solución**: Revisa los logs en la consola de Flutter. Si ves "Error al guardar en tabla User_login", ejecuta el script SQL de configuración.
