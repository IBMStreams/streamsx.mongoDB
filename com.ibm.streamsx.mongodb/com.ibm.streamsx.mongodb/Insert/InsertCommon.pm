package InsertCommon;

use strict;
use warnings;


sub buildBSONObjectWithKey(@) {
	my ($exprLocation, $attrName, $cppExpr, $splType) = @_;
	my $seq = 0;
	
	if ($attrName) {
		$seq++;
	
print qq(
	BSONObjBuilder b0;
);
	
	}
		
	my ($appendFunction, $value) = BSONCommon::buildBSONObject($exprLocation, $cppExpr, $splType, $seq);
	
	if ($attrName) {

print qq(
	b0.$appendFunction($attrName, $value);
);
	
	}
}


sub keyLess($) {
	my ($splType) = @_;
	return not (SPL::CodeGen::Type::isBMap($splType) || SPL::CodeGen::Type::isMap($splType) || SPL::CodeGen::Type::isTuple($splType));
}

1;
