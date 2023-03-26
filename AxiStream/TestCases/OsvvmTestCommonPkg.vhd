library OSVVM ; 
context OSVVM.OsvvmContext ; 
package OsvvmTestCommonPkg is
  constant RESULTS_DIR   : string := "" ;
  constant OSVVM_VALIDATED_RESULTS_DIR : string := osvvm.OsvvmScriptSettingsPkg.OSVVM_HOME_DIRECTORY & "/AXI4/AxiStream/ValidatedResults/" ;
end package OsvvmTestCommonPkg ; 
