
package Query_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   	use File::Basename qw(dirname);
   	use QueryCommon;
   
   	unshift @INC, dirname($model->getContext()->getOperatorDirectory()) . '/Common';
   	require BSONCommon;
   
   	my $db = $model->getParameterByName('dbName')->getValueAt(0)->getCppExpression();
   	my $collection = $model->getParameterByName('collection')->getValueAt(0)->getCppExpression();
   
   	my $dbHost = $model->getParameterByName('dbHost')->getValueAt(0)->getCppExpression();
   	my $dbPort = ($_ = $model->getParameterByName('dbPort')) ? $_->getValueAt(0)->getCppExpression() : 27017;
   
   	my $findFieldsExpr = ($_ = $model->getParameterByName('findFields')) ? $_->getValueAt(0) : undef;
   	my $findQueryExpr = ($_ = $model->getParameterByName('findQuery')) ? $_->getValueAt(0) : undef;
   	SPL::CodeGen::errorln("The type '%s' of findQuery parameter is not a string, map or tuple.", $findQueryExpr->getSPLType(), $findQueryExpr->getSourceLocation())
   		if (defined $findQueryExpr && QueryCommon::keyLess($findQueryExpr->getSPLType()) && not SPL::CodeGen::Type::isString($findQueryExpr->getSPLType()));
   
   	my $nToReturn = ($_ = $model->getParameterByName('nToReturn')) ? $_->getValueAt(0)->getCppExpression() : 0;
   	my $timeout = ($_ = $model->getParameterByName('timeout')) ? $_->getValueAt(0)->getCppExpression() : 0.0;
   	my $profiling = ($_ = $model->getParameterByName('profiling')) ? $_->getValueAt(0)->getSPLExpression() : 'off';
   	my $autoReconnect = ($_ = $model->getParameterByName('autoReconnect')) ? $_->getValueAt(0)->getCppExpression() : 'true';
   
   	my $inputPort = $model->getInputPortAt(0);
   	my $outputPort = $model->getOutputPortAt(0);
   	my $inTuple = $inputPort->getCppTupleName();
   print "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildConnUrl(const string& dbHost, uint32_t dbPort) {', "\n";
   print '	string connUrl = dbHost;', "\n";
   print '	connUrl += ":"; ', "\n";
   print '	connUrl += spl_cast<rstring,uint32_t>::cast(dbPort);', "\n";
   print '	return connUrl;', "\n";
   print '}', "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildDbCollection(const string& db, const string& collection) {', "\n";
   print '	string dbCollection(db);', "\n";
   print '	dbCollection += ".";', "\n";
   print '	dbCollection += collection;', "\n";
   print '	return dbCollection;', "\n";
   print '}', "\n";
   print "\n";
   print 'BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindFieldsBO() {', "\n";
   if (defined $findFieldsExpr) {
   	BSONCommon::buildBSONObject($findFieldsExpr->getSourceLocation(), $findFieldsExpr->getCppExpression(), $findFieldsExpr->getSPLType(), 0);
   print "\n";
   print '	return b0.obj();', "\n";
   }
   else {
   print "\n";
   print '	return BSONObj();', "\n";
   }
   print "\n";
   print '}', "\n";
   print "\n";
   print 'BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindQueryBO() {', "\n";
   if (defined $findQueryExpr && not $findQueryExpr->hasStreamAttributes()) {
   	if (SPL::CodeGen::Type::isString($findQueryExpr->getSPLType())) {
   print "\n";
   print '	 try {', "\n";
   print '		 return fromjson(';
   print $findQueryExpr->getCppExpression();
   print '.c_str());', "\n";
   print '	 }', "\n";
   print '	 catch(MsgAssertionException e) {', "\n";
   print '		 THROW(SPL::SPLRuntimeOperator, "FindQuery JSON string is not valid" << std::endl << e.what());', "\n";
   print '	 }', "\n";
   print '	';
   }
   	else {
   	 BSONCommon::buildBSONObject($findQueryExpr->getSourceLocation(), $findQueryExpr->getCppExpression(), $findQueryExpr->getSPLType(), 0);
   print "\n";
   print '	 return b0.obj();', "\n";
   print '	';
   }
   }
   else {
   print "\n";
   print '	 return BSONObj();', "\n";
   }
   print "\n";
   print '}', "\n";
   print "\n";
   print 'BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindQueryBO(Tuple const & tuple) {', "\n";
   print '	', "\n";
   for (my $i = 0; $i < $model->getNumberOfInputPorts(); $i++) {
   print "\n";
   print '  IPort';
   print $i;
   print 'Type const & ';
   print $model->getInputPortAt($i)->getCppTupleName();
   print ' = static_cast<IPort';
   print $i;
   print 'Type const&>(tuple);', "\n";
   }
   print "\n";
   print '	', "\n";
   if (defined $findQueryExpr) {
   	if (SPL::CodeGen::Type::isString($findQueryExpr->getSPLType())) {
   print "\n";
   print '	 try {', "\n";
   print '		 return fromjson(';
   print $findQueryExpr->getCppExpression();
   print '.c_str());', "\n";
   print '	 }', "\n";
   print '	 catch(MsgAssertionException e) {', "\n";
   print '		 THROW(SPL::SPLRuntimeOperator, "FindQuery JSON string is not valid" << std::endl << e.what());', "\n";
   print '	 }', "\n";
   print '	';
   }
   	else {
   	 BSONCommon::buildBSONObject($findQueryExpr->getSourceLocation(), $findQueryExpr->getCppExpression(), $findQueryExpr->getSPLType(), 0);
   print "\n";
   print '	 return b0.obj();', "\n";
   print '	';
   }
   }
   else {
   print "\n";
   print '	 return BSONObj();', "\n";
   }
   print "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR() : nQueriesMetric_(getContext().getMetrics().getCustomMetricByName("nQueries")),', "\n";
   print '							 findFieldsBO_(';
   print ((defined $findFieldsExpr && not $findFieldsExpr->hasStreamAttributes()) ? 'buildFindFieldsBO()' : 'BSONObj()');
   print '),', "\n";
   print '							 findQueryBO_(';
   print ((defined $findQueryExpr && not $findQueryExpr->hasStreamAttributes()) ? 'buildFindQueryBO()' : 'BSONObj()');
   print ') {', "\n";
   print "\n";
   print '	if(!MongoInit<void>::status_.isOK()) {', "\n";
   print '		THROW(SPL::SPLRuntimeOperator, "MongoDB initialization failed");', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady() {', "\n";
   print '	', "\n";
   print '	try {', "\n";
   print '		DBClientConnection conn;', "\n";
   print '		conn.connect(buildConnUrl(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print '));', "\n";
   print '	}', "\n";
   print '	catch( const DBException &e ) {', "\n";
   print '		if (';
   print $autoReconnect;
   print ')', "\n";
   print '			SPLAPPLOG(L_ERROR, e.what(), "MongoDB Connect");', "\n";
   print '		else', "\n";
   print '			THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown() {', "\n";
   print '	client::shutdown();', "\n";
   print '}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port) {', "\n";
   print '	';
   for (my $i = 0; $i < $model->getNumberOfInputPorts(); $i++) {
   print "\n";
   print '	  IPort';
   print $i;
   print 'Type const & ';
   print $model->getInputPortAt($i)->getCppTupleName();
   print ' = static_cast<IPort';
   print $i;
   print 'Type const&>(tuple);', "\n";
   print '	';
   }
   print "\n";
   print '	OPort0Type * otuplePtr = getOutputTuple();', "\n";
   print '	', "\n";
   print '	';
   foreach my $attribute (@{$outputPort->getAttributes()}) {
   	  my $attrName = $attribute->getName();
   	  if ($attribute->hasAssignmentWithOutputFunction()) {
   	  	if ($attribute->getAssignmentOutputFunctionName() eq 'AsIs') {
   			my $assign = $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   print "\n";
   print '			otuplePtr->set_';
   print $attrName;
   print '(';
   print $assign;
   print ');', "\n";
   print '		';
   }
   	  }
   	  elsif ($attribute->hasAssignment()) {
   			my $assign = $attribute->getAssignmentValue()->getCppExpression();
   print "\n";
   print '			otuplePtr->set_';
   print $attrName;
   print '(';
   print $assign;
   print ');', "\n";
   print '	  ';
   }
   	}
   print "\n";
   print "\n";
   print '	';
   if (defined $findFieldsExpr && $findFieldsExpr->hasStreamAttributes()) {
   print "\n";
   print '		const BSONObj & findFieldsBO = buildFindFieldsBO();', "\n";
   print '	';
   }
   	else {
   print "\n";
   print '		const BSONObj & findFieldsBO = findFieldsBO_;', "\n";
   print '	';
   }
   print "\n";
   print "\n";
   print '	';
   if (defined $findQueryExpr && $findQueryExpr->hasStreamAttributes()) {
   print "\n";
   print '		const BSONObj & findQueryBO = buildFindQueryBO(tuple);', "\n";
   print '	';
   }
   	else {
   print "\n";
   print '		const BSONObj & findQueryBO = findQueryBO_;', "\n";
   print '	';
   }
   print "\n";
   print '	', "\n";
   print '	bool docFound = false;', "\n";
   print "\n";
   print '	DBClientConnection * connPtr = getDBClientConnection(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print ');', "\n";
   print "\n";
   print '	if(connPtr->isFailed()) {', "\n";
   print '		if (';
   print $autoReconnect;
   print ') {', "\n";
   print '			SPLAPPLOG(L_ERROR, "Trying to reconnect to " << ';
   print $dbHost;
   print ' << ":" << ';
   print $dbPort;
   print ', "MongoDB Connect");', "\n";
   print '			connPtr->isStillConnected();', "\n";
   print '		}', "\n";
   print '		else {', "\n";
   print '			THROW(SPL::SPLRuntimeOperator, "Connection to " << ';
   print $dbHost;
   print ' << ":" << ';
   print $dbPort;
   print ' << " aborted");', "\n";
   print '		}', "\n";
   print '	}', "\n";
   print '		', "\n";
   print '	';
   if ($profiling eq 'slow') {
   print "\n";
   print '		connPtr->DBClientWithCommands::setDbProfilingLevel(';
   print $db;
   print ',  DBClientWithCommands::ProfileSlow);', "\n";
   print '	';
   } elsif ($profiling eq 'all') {
   print "\n";
   print '		connPtr->DBClientWithCommands::setDbProfilingLevel(';
   print $db;
   print ',  DBClientWithCommands::ProfileAll);', "\n";
   print '	';
   }
   print "\n";
   print '	', "\n";
   print '	streams_boost::scoped_ptr<DBClientCursor> cursor(connPtr->query(buildDbCollection(';
   print $db;
   print ', ';
   print $collection;
   print '),', "\n";
   print '																	findQueryBO,', "\n";
   print '																	';
   print $nToReturn;
   print ', 0,', "\n";
   print '																	&findFieldsBO,', "\n";
   print '																	0, 0));', "\n";
   print '	const string & errorMsg = connPtr->getLastError();', "\n";
   print '	if (errorMsg != "") {', "\n";
   print '		SPLAPPLOG(L_ERROR, errorMsg, "MongoDB Query");', "\n";
   print '	}', "\n";
   print '	else {', "\n";
   print '		nQueriesMetric_.incrementValue();', "\n";
   print "\n";
   print '		docFound = cursor->more();', "\n";
   print '		while (cursor->more()) {', "\n";
   print '			const BSONObj & queryResultBO = cursor->next();', "\n";
   print '			OPort0Type otuple(*otuplePtr);', "\n";
   print '			size_t tupleHash = otuple.hashCode();', "\n";
   print "\n";
   # [----- perl code -----]
   		foreach my $attribute (@{$outputPort->getAttributes()}) {
   			my $attrName = $attribute->getName();
   			my $attrType = $attribute->getSPLType();
   			my $attrFN = $attribute->getAssignmentOutputFunctionName() if $_ = $attribute->hasAssignmentWithOutputFunction();
   			if ($_ && $attrFN ne 'AsIs') {
   				if ($attrFN eq 'QueryDocumentFieldAsJson') {
   					QueryCommon::handleBSONObjectAsJson($attrName, $attrType);
   				}
   				else {
   					my $attrNameNotInBO = $attrFN eq 'QueryDocumentMultipleFields';
   					my $exprLocation = $attribute->getAssignmentSourceLocation();
   					my $cppType = $attribute->getCppType();
   					my $numberOfParams = @{$attribute->getAssignmentOutputFunctionParameterValues};
   					my $findPath = $numberOfParams > 0 ? $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression() : '';
   	
   					QueryCommon::initBSONObject($attrName, $attrNameNotInBO, $cppType, $findPath);
   	
   					QueryCommon::handleBSONObject($exprLocation, $attrName, $attrType, 0);
   	
   					QueryCommon::endBSONObject();
   				}
   			}
   		}
   # [----- perl code -----]
   print "\n";
   print "\n";
   print '			if(otuple.hashCode() != tupleHash) submit(otuple, 0);', "\n";
   print '		}', "\n";
   print '	', "\n";
   print '		if(docFound) {', "\n";
   print '			submit(Punctuation::WindowMarker, 0);', "\n";
   print '		}', "\n";
   print '		else {', "\n";
   print '			submit(*otuplePtr, 0);', "\n";
   print '		}', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print '// static thread_specific_ptr initialization', "\n";
   print 'streams_boost::thread_specific_ptr<MY_OPERATOR_SCOPE::MY_OPERATOR::OPort0Type> MY_OPERATOR_SCOPE::MY_OPERATOR::otuplePtr_;', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::OPort0Type * MY_OPERATOR_SCOPE::MY_OPERATOR::getOutputTuple() {', "\n";
   print '	OPort0Type * otuplePtr = otuplePtr_.get();', "\n";
   print '	if(!otuplePtr) {', "\n";
   print '		otuplePtr_.reset(new OPort0Type());', "\n";
   print '		otuplePtr_->clear();', "\n";
   print '		otuplePtr = otuplePtr_.get();', "\n";
   print '	}', "\n";
   print '	return otuplePtr;', "\n";
   print '}', "\n";
   print "\n";
   print '// static thread_specific_ptr initialization', "\n";
   print 'streams_boost::thread_specific_ptr<DBClientConnection> MY_OPERATOR_SCOPE::MY_OPERATOR::connPtr_;', "\n";
   print "\n";
   print 'DBClientConnection * MY_OPERATOR_SCOPE::MY_OPERATOR::getDBClientConnection(const string& dbHost, uint32_t dbPort) {', "\n";
   print '	DBClientConnection * connPtr = connPtr_.get();', "\n";
   print '	if(!connPtr) {', "\n";
   print '		connPtr_.reset(new DBClientConnection(';
   print $autoReconnect;
   print ', 0, (double)';
   print $timeout;
   print '));', "\n";
   print '		connPtr = connPtr_.get();', "\n";
   print "\n";
   print '		try {', "\n";
   print '			connPtr->connect(buildConnUrl(dbHost, dbPort));', "\n";
   print '		}', "\n";
   print '		catch( const DBException &e ) {', "\n";
   print '			if (';
   print $autoReconnect;
   print ')', "\n";
   print '				SPLAPPLOG(L_ERROR, e.what(), "MongoDB Connect");', "\n";
   print '			else', "\n";
   print '				THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '		}', "\n";
   print '	}', "\n";
   print '	return connPtr;', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
